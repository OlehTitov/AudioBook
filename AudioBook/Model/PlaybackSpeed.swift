//
//  PlaybackSpeed.swift
//  AudioBook
//
//  Created by Oleh Titov on 02.06.2024.
//

import Foundation

enum PlaybackSpeed: Float, CaseIterable {
    case half = 0.5
    case threeQuarter = 0.75
    case normal = 1.0
    case oneAndQuarter = 1.25
    case oneAndHalf = 1.5
    case oneAndThreeQuarter = 1.75
    case double = 2.0

    mutating func next() {
        let allCases = Self.allCases
        if let currentIndex = allCases.firstIndex(of: self), currentIndex + 1 < allCases.count {
            self = allCases[currentIndex + 1]
        } else {
            self = allCases.first!
        }
    }
}
