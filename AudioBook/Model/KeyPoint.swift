//
//  KeyPoint.swift
//  AudioBook
//
//  Created by Oleh Titov on 02.06.2024.
//

import Foundation

struct KeyPoint: Equatable, Identifiable {
    let id: UUID
    let audioFileURL: URL
    let title: String
}
