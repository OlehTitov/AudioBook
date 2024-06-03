//
//  InteractiveButtonStyle.swift
//  AudioBook
//
//  Created by Oleh Titov on 02.06.2024.
//

import Foundation
import SwiftUI

struct InteractiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .fontWeight(.medium)
            .padding()
//            .padding(6)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.secondary.opacity(0.2) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.3)
            .animation(.easeInOut, value: isEnabled)
    }
}
