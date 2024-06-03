//
//  AudioBookApp.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct AudioBookApp: App {
    static let store = Store(initialState: BookSummary.State()) {
        BookSummary()
//            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            BookSummaryView(store: AudioBookApp.store)
        }
    }
}
