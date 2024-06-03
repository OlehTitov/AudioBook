//
//  BundleSummaryLoader.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import Foundation

//This is a loader for files in the bundle.
//We can easily replace it with NetworkSummaryLoader and use it in LiveSummaryLoaderClient
struct BundleSummaryLoader {
    static func loadSummary() async throws -> Summary {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                do {
                    guard let keyPoint1URL = Bundle.main.url(forResource: "part-1", withExtension: "mp3"),
                          let keyPoint2URL = Bundle.main.url(forResource: "part-2", withExtension: "mp3"),
                          let keyPoint3URL = Bundle.main.url(forResource: "part-3", withExtension: "mp3"),
                          let keyPoint4URL = Bundle.main.url(forResource: "part-4", withExtension: "mp3"),
                          let coverImageURL = Bundle.main.url(forResource: "the-art-of-war", withExtension: "jpg") else {
                              throw NSError(domain: "FileNotFound", code: 404, userInfo: nil)
                          }
                    
                    let keyPoints = [
                        KeyPoint(id: UUID(), audioFileURL: keyPoint1URL, title: "Laying plans"),
                        KeyPoint(id: UUID(), audioFileURL: keyPoint2URL, title: "Waging war"),
                        KeyPoint(id: UUID(), audioFileURL: keyPoint3URL, title: "Attack by stratagem"),
                        KeyPoint(id: UUID(), audioFileURL: keyPoint4URL, title: "Tactical disposition")
                    ]
                    
                    let summary = Summary(id: UUID(), title: "The Art of War", coverImageURL: coverImageURL, keyPoints: keyPoints)
                    continuation.resume(returning: summary)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
