//
//  CascadingAnimation.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

// MARK: - Modifier para animações em cascata
struct CascadingAnimationModifier: ViewModifier {
    let index: Int
    let baseDelay: Double

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.95)
            .onAppear {
                withAnimation(
                    .easeOut.delay(Double(index) * baseDelay)
                ) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Extensão para usar fácil
extension View {
    func cascadingAnimation(index: Int, baseDelay: Double = 0.1) -> some View {
        self.modifier(CascadingAnimationModifier(index: index, baseDelay: baseDelay))
    }
}
