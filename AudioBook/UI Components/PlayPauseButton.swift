//
//  PlayPauseButton.swift
//  AudioBook
//
//  Created by Oleh Titov on 02.06.2024.
//

import SwiftUI

struct PlayPauseButton: View {
    var isPlaying: Bool
    var isAudioReady: Bool
    var action: () -> Void
    var disabled: Bool
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack{
                if isAudioReady {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .padding(4)
                } else {
                    ProgressView()
                }
            }
        }
        .hapticOnTouch()
        .buttonStyle(InteractiveButtonStyle())
        .disabled(disabled)
    }
}

#Preview {
    PlayPauseButton(isPlaying: true, isAudioReady: true, action: {}, disabled: false)
}
