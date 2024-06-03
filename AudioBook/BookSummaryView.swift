//
//  BookSummaryView.swift
//  AudioBook
//
//  Created by Oleh Titov on 03.06.2024.
//
import ComposableArchitecture
import SwiftUI

struct BookSummaryView: View {
    @Bindable var store: StoreOf<BookSummary>
    
    var body: some View {
        VStack {
            switch store.uiState {
            case .loading:
                VStack {
                    Image(uiImage: AppIconProvider.appIcon())
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    ProgressView("Loading...")
                }
            case .error(let message):
                Text(message)
            case .loaded(let summary):
                GeometryReader { geo in
                    VStack {
                        BookCover(url: summary.coverImageURL, width: geo.size.height*0.33, height: geo.size.height*0.5)
                        
                        Text("Key point \(store.currentKeyPointIndex + 1) of \(summary.keyPoints.count)".uppercased())
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding()
                        Text(summary.keyPoints[store.currentKeyPointIndex].title)
                        
                        HStack {
                            Text(dateComponentsFormatter.string(from: store.currentProgress) ?? "0:00")
                                .font(.footnote.monospacedDigit())
                                .foregroundColor(Color(.systemGray))
                            
                            Slider(
                                value: Binding(
                                    get: { store.currentProgress },
                                    set: { newValue in
                                        store.send(.sliderChanged(newValue, isScrubbing: true))
                                    }
                                ),
                                in: 0...store.duration,
                                onEditingChanged: { editing in
                                    if !editing {
                                        store.send(.sliderChanged(store.currentProgress, isScrubbing: false))
                                    }
                                }
                            )
                            
                            Text(dateComponentsFormatter.string(from: store.duration) ?? "0:00")
                                .font(.footnote.monospacedDigit())
                                .foregroundColor(Color(.systemGray))
                        }
                        .padding()
                        
                        Button {
                            Haptics.shared.select()
                            store.send(.playbackSpeedTapped)
                        } label: {
                            Text("\(store.currentPlaybackSpeed.rawValue.formatted())x speed")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .animation(nil)
                        }
                        .tint(Color.primary)
                        .padding(8)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Spacer()

                    }
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            PlayerControlButton(
                                icon: "backward.end.fill",
                                action: {store.send(.previousChapterTapped)},
                                disabled: store.currentKeyPointIndex == 0
                            )
                            
                            PlayerControlButton(
                                icon: "gobackward.5",
                                action: {store.send(.rewindTapped)}
                            )
                            
                            PlayPauseButton(
                                isPlaying: store.playbackMode == .playing,
                                isAudioReady: store.audioIsReady,
                                action: {
                                    Haptics.shared.play(.medium)
                                    store.send(.playPauseTapped)
                                },
                                disabled: !store.audioIsReady
                            )
                            
                            PlayerControlButton(
                                icon: "goforward.10",
                                action: {store.send(.forwardTapped)}
                            )
                            
                            PlayerControlButton(
                                icon: "forward.end.fill",
                                action: {store.send(.nextChapterTapped)},
                                disabled: store.currentKeyPointIndex >= summary.keyPoints.count - 1
                            )
                        }
                        //Setting frame height to prevent view from jerking when buttons scale onPressed
                        .frame(height: 100)
                        .padding(.bottom)
                    }
                }
                
            }
            
        }
        .onAppear {
            store.send(.loadSummary)
        }
    }
}

#Preview {
    BookSummaryView(
        store: Store(initialState: BookSummary.State()) {
            BookSummary()
        }
    )
}
