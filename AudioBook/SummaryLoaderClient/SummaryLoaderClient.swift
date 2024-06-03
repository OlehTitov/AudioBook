//
//  SummaryLoaderClient.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct SummaryLoaderClient {
    var loadSummary: @Sendable () async throws -> Summary
}

extension SummaryLoaderClient: TestDependencyKey {
    static let previewValue = Self(
        loadSummary: {
            Summary(
                id: UUID(),
                title: "",
                coverImageURL: Bundle.main.url(forResource: "the-art-of-war", withExtension: "jpg")!,
                keyPoints: [
                    KeyPoint(id: UUID(), audioFileURL: URL(string: "part-1")!, title: "Laying plans"),
                    KeyPoint(id: UUID(), audioFileURL: URL(string: "part-2")!, title: "Waging war")
                ]
            )
        }
    )

    static let testValue = Self(
        loadSummary: {
            Summary(
                id: UUID(),
                title: "mock summary",
                coverImageURL: URL(string: "the-art-of-war")!,
                keyPoints: [
                    KeyPoint(id: UUID(), audioFileURL: URL(string: "part-1")!, title: "Laying plans"),
                    KeyPoint(id: UUID(), audioFileURL: URL(string: "part-2")!, title: "Waging war")
                ]
            )
        }
    )
}

extension DependencyValues {
    var summaryLoader: SummaryLoaderClient {
        get { self[SummaryLoaderClient.self] }
        set { self[SummaryLoaderClient.self] = newValue }
    }
}
