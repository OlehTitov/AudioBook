//
//  AudioBookTests.swift
//  AudioBookTests
//
//  Created by Oleh Titov on 02.06.2024.
//

import ComposableArchitecture
import XCTest

@testable import AudioBook

final class AudioBookTests: XCTestCase {

    func testInitialState() {
        let store = TestStore(
            initialState: BookSummary.State()) {
                BookSummary()
            }

        XCTAssertEqual(store.state.uiState, .loading)
        XCTAssertEqual(store.state.audioIsReady, false)
        XCTAssertEqual(store.state.currentKeyPointIndex, 0)
        XCTAssertEqual(store.state.playbackMode, .notPlaying)
        XCTAssertEqual(store.state.duration, 0.0)
        XCTAssertEqual(store.state.currentProgress, 0.0)
        XCTAssertEqual(store.state.currentPlaybackSpeed, .normal)
    }
    
    @MainActor
    func testPlayPauseTapped() async {
        let url = URL(fileURLWithPath: "/mock/path/to/audio.mp3")
        let summaryId = UUID()
        let keypointId = UUID()
        let clock = TestClock()
        let store = TestStore(
            initialState: BookSummary.State(
                summary: Summary(id: summaryId, title: "Mock summary", coverImageURL: url, keyPoints: [KeyPoint(id: keypointId, audioFileURL: url, title: "Key point 1")]),
                uiState: .loaded(Summary(id: summaryId, title: "Mock summary", coverImageURL: url, keyPoints: [KeyPoint(id: keypointId, audioFileURL: url, title: "Key point 1")])),
                audioIsReady: true,
                currentKeyPointIndex: 0,
                playbackMode: .notPlaying,
                duration: 12.0,
                currentProgress: 0.0,
                currentPlaybackSpeed: .normal,
                errorMessage: ""
            )
        ) {
            BookSummary()
        } withDependencies: {
            $0.summaryLoader = .testValue
            $0.continuousClock = clock
        }
        
        await store.send(.playPauseTapped) {
            $0.playbackMode = .playing
        }
        
        await store.receive(\.startTimer)
        
        await clock.advance(by: .seconds(1))
        
//        await store.receive(\.timerUpdated(1)) {
//            $0.currentProgress = 1.0
//        }

    }

}
