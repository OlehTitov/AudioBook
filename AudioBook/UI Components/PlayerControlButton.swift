//
//  PlayerControlButton.swift
//  AudioBook
//
//  Created by Oleh Titov on 01.06.2024.
//

import SwiftUI

struct PlayerControlButton: View {
    var icon: String
    var action: () -> Void
    var disabled: Bool?
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: icon)
        }
        .hapticOnTouch()
        .buttonStyle(InteractiveButtonStyle())
        .disabled(disabled ?? false)
    }
}

#Preview {
    PlayerControlButton(icon: "backward.end.fill", action: {}, disabled: false)
}
