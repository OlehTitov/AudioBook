//
//  LiveSummaryLoaderClient.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import Foundation
import Dependencies

extension SummaryLoaderClient: DependencyKey {
    static let liveValue = Self(
        loadSummary: {
            try await BundleSummaryLoader.loadSummary()
        }
    )
}
