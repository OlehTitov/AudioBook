//
//  HapticOnTouch.swift
//  AudioBook
//
//  Created by Oleh Titov on 02.06.2024.
//

import Foundation
import SwiftUI
///Source: https://stackoverflow.com/questions/75064476/how-can-i-add-haptics-on-initial-press-of-a-button-in-swift-not-after-the-butto

struct HapticOnTouch: ViewModifier {
    @State var isDragging: Bool = false

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isDragging {
                            let impactLight = UIImpactFeedbackGenerator(style: .light)
                            impactLight.impactOccurred()
                        }

                        isDragging = true
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
    }
}

extension View {
    func hapticOnTouch() -> some View {
        modifier(HapticOnTouch())
    }
}
