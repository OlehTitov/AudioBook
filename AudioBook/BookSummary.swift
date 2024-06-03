//
//  BookSummary.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct BookSummary {
    //MARK: - State
    @ObservableState
    struct State: Equatable {
        var summary: Summary?
        var uiState: UIState = .loading
        var audioIsReady = false
        var currentKeyPointIndex: Int = 0
        var playbackMode: PlaybackMode = .notPlaying
        var duration: TimeInterval = 0.0
        var currentProgress: TimeInterval = 0.0
        var currentPlaybackSpeed: PlaybackSpeed = .normal
        var errorMessage = ""
        
        @CasePathable
        @dynamicMemberLookup
        enum PlaybackMode: Equatable {
            case notPlaying
            case playing
        }
        
        enum UIState: Equatable {
            case loading
            case loaded(Summary)
            case error(String)
        }
    }
    
    //MARK: - Actions
    enum Action {
        case loadSummary
        case summaryLoaded(Result<Summary, Error>)
        case audioPlayerClient(Result<Bool, Error>)
        case initializePlayer(URL)
        case playPauseTapped
        case previousChapterTapped
        case nextChapterTapped
        case rewindTapped
        case forwardTapped
        case playbackSpeedTapped
        case setDuration(TimeInterval)
        case timerUpdated(TimeInterval)
        case delegate(Delegate)
        case startTimer
        case setAudioIsReady(Bool)
        case sliderChanged(TimeInterval, isScrubbing: Bool)
        
        @CasePathable
        enum Delegate {
            case playbackStarted
            case playbackFailed
            case playbackTimeDidChanged
            case keyPointDidChanged
        }
    }
    
    @Dependency(\.summaryLoader) var summaryLoader
    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case play, timer }
    
    //MARK: - Reducer
    var body: some ReducerOf<Self>  {
        Reduce { state, action in
            switch action {
            case .loadSummary:
                return .run { send in
                    do {
                        let summary = try await summaryLoader.loadSummary()
                        let keyPoint = summary.keyPoints.first
                        if let keyPointURL = keyPoint?.audioFileURL {
                            let duration = try audioPlayer.loadDuration(url: keyPointURL)
                            await send(.setDuration(duration))
                        }
                    
                        await send(.summaryLoaded(.success(summary)))
                    } catch {
                        await send(.summaryLoaded(.failure(error)))
                    }
                }
                
            case .summaryLoaded(let result):
                switch result {
                case .success(let summary):
                    state.summary = summary
                    state.uiState = .loaded(summary)
                    state.currentKeyPointIndex = 0
                    state.playbackMode = .playing
                    if let keyPointURL = summary.keyPoints.first?.audioFileURL {
                        return .merge(
                            .send(.initializePlayer(keyPointURL))
                        )
                    }
                case .failure(let error):
                    state.uiState = .error("Failed to load summary: \(error.localizedDescription)")
                }
                return .none
                
            case .playPauseTapped:
                guard case .loaded(_) = state.uiState else {
                    return .none
                }
                switch state.playbackMode {
                case .notPlaying:
                    state.playbackMode = .playing
                    self.audioPlayer.resumePlaying()
                    return .send(.startTimer)
                case .playing:
                    state.playbackMode = .notPlaying
                    return .merge(
                        .run { send in
                            self.audioPlayer.pause()
                        },
                        .cancel(id: CancelID.timer)
                    )
                }
            case .previousChapterTapped:
                guard state.currentKeyPointIndex > 0 else { return .none }
                state.currentKeyPointIndex -= 1
                state.currentProgress = 0.0
                if state.playbackMode == .notPlaying {
                    state.playbackMode = .playing
                }
                return .send(.delegate(.keyPointDidChanged))
                
            case .nextChapterTapped:
                guard let summary = state.summary, state.currentKeyPointIndex < summary.keyPoints.count - 1 else { return .none }
                state.currentKeyPointIndex += 1
                state.currentProgress = 0.0
                if state.playbackMode == .notPlaying {
                    state.playbackMode = .playing
                }
                return .send(.delegate(.keyPointDidChanged))
                
            case .rewindTapped:
                if state.playbackMode == .notPlaying {
                    state.playbackMode = .playing
                }
                state.currentProgress = max(state.currentProgress - 5, 0)
                return .send(.delegate(.playbackTimeDidChanged))
                
            case .forwardTapped:
                if state.playbackMode == .notPlaying {
                    state.playbackMode = .playing
                }
                state.currentProgress = min(state.currentProgress + 10, state.duration)
                return .send(.delegate(.playbackTimeDidChanged))
            
            case .playbackSpeedTapped:
                state.currentPlaybackSpeed.next()
                let newSpeed = state.currentPlaybackSpeed.rawValue
                return .merge (
                    .run{ _ in
                        self.audioPlayer.setSpeedTo(speed: newSpeed)
                    },
                    .cancel(id: CancelID.timer),
                    state.playbackMode == .playing ? .send(.startTimer) : .none
                )
            
            case .setDuration(let duration):
                state.duration = duration
                return .none
            
            case let .timerUpdated(time):
                state.currentProgress = time
                return .none
            
            case .delegate(.playbackStarted):
                return .none
                
            case .delegate(.playbackFailed):
                state.playbackMode = .notPlaying
                state.uiState = .error("Playback error")
                return .none
                
            case .delegate(.playbackTimeDidChanged):
                return .merge(
                    .cancel(id: CancelID.timer),
                    .run { [progress = state.currentProgress] send in
                        try audioPlayer.seek(progress)
                        await send(.timerUpdated(progress))
                        self.audioPlayer.resumePlaying()
                    },
                    .send(.startTimer)
                )
                
            case .delegate(.keyPointDidChanged):
                guard let summary = state.summary else {return .none}
                return .merge(
                    .cancel(id: CancelID.play),
                    .cancel(id: CancelID.timer),
                    .run { [currentIndex = state.currentKeyPointIndex] send in
                        let newKeyPoint = summary.keyPoints[currentIndex]
                        let duration = try audioPlayer.loadDuration(url: newKeyPoint.audioFileURL)
                        await send(.setDuration(duration))
                        await send(.initializePlayer(newKeyPoint.audioFileURL))
                    },
                    .send(.startTimer)
                )
                
            case .audioPlayerClient(.failure):
                return .merge(
                    .cancel(id: CancelID.play),
                    .send(.delegate(.playbackFailed))
                )

            case .audioPlayerClient:
                state.playbackMode = .notPlaying
                print("Finished playing...")
                return .merge(
                    .cancel(id: CancelID.play),
                    .cancel(id: CancelID.timer)
                )
                    
            case .startTimer:
                return .run { [progress = state.currentProgress, speed = state.currentPlaybackSpeed.rawValue] send in
                    var start = progress
                    let interval = 0.1
                    for await _ in self.clock.timer(interval: .seconds(interval)) {
                        start += interval * Double(speed)
                        await send(.timerUpdated(start))
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
                
            case .initializePlayer(let url):
                return .merge (
                    .run{ [currentSpeed = state.currentPlaybackSpeed.rawValue] send in
                        await send(.startTimer)
                        async let playAudio: Void = send(
                            .audioPlayerClient(Result { try await self.audioPlayer.initialize(url: url, speed: currentSpeed) })
                        )
                        await playAudio
                    }
                    .cancellable(id: CancelID.play, cancelInFlight: true),
                    
                    .send(.setAudioIsReady(true))
                )
                
            case .setAudioIsReady(let isReady):
                state.audioIsReady = isReady
                return .none
            
            case .sliderChanged(let newTime, let isScrubbing):
                state.currentProgress = newTime
                if isScrubbing {
                    switch state.playbackMode {
                    case .notPlaying:
                        return .none
                    case .playing:
                        return .merge(
                            .cancel(id: CancelID.timer)
                        )
                    }
                } else {
                    switch state.playbackMode {
                    case .notPlaying:
                        state.playbackMode = .playing
                        return .send(.delegate(.playbackTimeDidChanged))
                    case .playing:
                        return .send(.delegate(.playbackTimeDidChanged))
                    }
                }
            }
            
        }
    }
}

//struct BookSummaryView: View {
//    @Bindable var store: StoreOf<BookSummary>
//    
//    var body: some View {
//        VStack {
//            switch store.uiState {
//            case .loading:
//                VStack {
//                    Image(uiImage: AppIconProvider.appIcon())
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
//                    ProgressView("Loading...")
//                }
//            case .error(let message):
//                Text(message)
//            case .loaded(let summary):
//                GeometryReader { geo in
//                    VStack {
//                        BookCover(url: summary.coverImageURL, width: geo.size.height*0.33, height: geo.size.height*0.5)
//                        
//                        Text("Key point \(store.currentKeyPointIndex + 1) of \(summary.keyPoints.count)".uppercased())
//                            .foregroundStyle(.secondary)
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .padding()
//                        Text(summary.keyPoints[store.currentKeyPointIndex].title)
//                        
//                        HStack {
//                            Text(dateComponentsFormatter.string(from: store.currentProgress) ?? "0:00")
//                                .font(.footnote.monospacedDigit())
//                                .foregroundColor(Color(.systemGray))
//                            
//                            Slider(
//                                value: Binding(
//                                    get: { store.currentProgress },
//                                    set: { newValue in
//                                        store.send(.sliderChanged(newValue, isScrubbing: true))
//                                    }
//                                ),
//                                in: 0...store.duration,
//                                onEditingChanged: { editing in
//                                    if !editing {
//                                        store.send(.sliderChanged(store.currentProgress, isScrubbing: false))
//                                    }
//                                }
//                            )
//                            
//                            Text(dateComponentsFormatter.string(from: store.duration) ?? "0:00")
//                                .font(.footnote.monospacedDigit())
//                                .foregroundColor(Color(.systemGray))
//                        }
//                        .padding()
//                        
//                        Button {
//                            Haptics.shared.select()
//                            store.send(.playbackSpeedTapped)
//                        } label: {
//                            Text("\(store.currentPlaybackSpeed.rawValue.formatted())x speed")
//                                .font(.footnote)
//                                .fontWeight(.bold)
//                                .animation(nil)
//                        }
//                        .tint(Color.primary)
//                        .padding(8)
//                        .background(Color.secondary.opacity(0.2))
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                        
//                        Spacer()
//
//                    }
//                    .safeAreaInset(edge: .bottom) {
//                        HStack {
//                            PlayerControlButton(
//                                icon: "backward.end.fill",
//                                action: {store.send(.previousChapterTapped)},
//                                disabled: store.currentKeyPointIndex == 0
//                            )
//                            
//                            PlayerControlButton(
//                                icon: "gobackward.5",
//                                action: {store.send(.rewindTapped)}
//                            )
//                            
//                            PlayPauseButton(
//                                isPlaying: store.playbackMode == .playing,
//                                isAudioReady: store.audioIsReady,
//                                action: {
//                                    Haptics.shared.play(.medium)
//                                    store.send(.playPauseTapped)
//                                },
//                                disabled: !store.audioIsReady
//                            )
//                            
//                            PlayerControlButton(
//                                icon: "goforward.10",
//                                action: {store.send(.forwardTapped)}
//                            )
//                            
//                            PlayerControlButton(
//                                icon: "forward.end.fill",
//                                action: {store.send(.nextChapterTapped)},
//                                disabled: store.currentKeyPointIndex >= summary.keyPoints.count - 1
//                            )
//                        }
//                        //Setting frame height to prevent view from jerking when buttons scale onPressed
//                        .frame(height: 100)
//                        .padding(.bottom)
//                    }
//                }
//                
//            }
//            
//        }
//        .onAppear {
//            store.send(.loadSummary)
//        }
//    }
//}
//
//#Preview {
//    BookSummaryView(
//        store: Store(initialState: BookSummary.State()) {
//            BookSummary()
//        }
//    )
//}
