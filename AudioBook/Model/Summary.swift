//
//  Summary.swift
//  AudioBook
//
//  Created by Oleh Titov on 02.06.2024.
//

import Foundation

struct Summary: Equatable, Identifiable {
    let id: UUID
    let title: String
    let coverImageURL: URL
    let keyPoints: [KeyPoint]
}
