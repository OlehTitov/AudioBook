//
//  SecondaryButton.swift
//  AudioBook
//
//  Created by Oleh Titov on 31.05.2024.
//

import SwiftUI
import ComposableArchitecture

struct SecondaryButton: View {
    var action: StoreTask
    var disabled: Bool
    var icon: String
    var body: some View {
        Button(action: {
            Task {
                await action
            }
        }) {
            Image(systemName: "forward.end.fill")
                .font(.title)
                .fontWeight(.medium)
                .padding(4)
        }
        .tint(Color.primary)
        .disabled(disabled)
    }
}

#Preview {
    SecondaryButton(action: .init {
        .none
    }, disabled: false, icon: "forward.end.fill")
}
