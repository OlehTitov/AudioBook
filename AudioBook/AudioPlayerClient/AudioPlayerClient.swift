//
//  AudioPlayerClient.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import Foundation
import ComposableArchitecture
import Dependencies
import AVFoundation

@DependencyClient
struct AudioPlayerClient {
    var pause: @Sendable () -> Void
    var loadDuration: @Sendable (_ url: URL) throws -> TimeInterval
    var initialize: @Sendable (_ url: URL, _ speed: Float) async throws -> Bool
    var seek: @Sendable (_ time: TimeInterval) throws -> Void
    var resumePlaying: @Sendable () -> Void
    var setSpeedTo: @Sendable (_ speed: Float) -> Void
}

extension AudioPlayerClient: DependencyKey {
    static let liveValue = Self(
        pause: {
            Delegate.shared?.pause()
        },
        loadDuration: { url in
            let player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        },
        initialize: { url, speed in
            let stream = AsyncThrowingStream<Bool, Error> { continuation in
                do {
                    let delegate = try Delegate(
                        url: url,
                        didFinishPlaying: { successful in
                            continuation.yield(successful)
                            continuation.finish()
                        },
                        decodeErrorDidOccur: { error in
                            continuation.finish(throwing: error)
                        }
                    )
                    delegate.player.enableRate = true
                    delegate.player.rate = speed
                    delegate.player.play()
                    continuation.onTermination = { _ in
                      delegate.player.stop()
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            return try await stream.first(where: { _ in true }) ?? false
        },
        seek: { time in
            Delegate.shared?.seek(to: time)
        },
        resumePlaying: {
            Delegate.shared?.resumePlaying()
        },
        setSpeedTo: { newSpeed in
            Delegate.shared?.setSpeed(newSpeed: newSpeed)
        }
        
    )

    static let previewValue = Self(
        pause: {},
        loadDuration: {_ in 0},
        initialize: { url, speed in true },
        seek: {time in },
        resumePlaying: {},
        setSpeedTo: {speed in}
    )

    static let testValue = Self(
        pause: {},
        loadDuration: {_ in 0},
        initialize: { url, speed in true  },
        seek: {time in },
        resumePlaying: {},
        setSpeedTo: {speed in}
    )
}

extension DependencyValues {
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

private final class Delegate: NSObject, AVAudioPlayerDelegate, @unchecked Sendable {
    static var shared: Delegate?

    let didFinishPlaying: @Sendable (Bool) -> Void
    let decodeErrorDidOccur: @Sendable (Error?) -> Void
    let player: AVAudioPlayer

    init(
        url: URL,
        didFinishPlaying: @escaping @Sendable (Bool) -> Void,
        decodeErrorDidOccur: @escaping @Sendable (Error?) -> Void
    ) throws {
        self.didFinishPlaying = didFinishPlaying
        self.decodeErrorDidOccur = decodeErrorDidOccur
        self.player = try AVAudioPlayer(contentsOf: url)
        super.init()
        self.player.delegate = self
        Delegate.shared = self
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.didFinishPlaying(flag)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.decodeErrorDidOccur(error)
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.stop()
        player.currentTime = 0
    }
    
    func seek(to time: TimeInterval) {
        player.currentTime = time
    }
    
    func resumePlaying() {
        player.play()
    }
    
    func setSpeed(newSpeed: Float) {
        player.rate = newSpeed
    }
}
