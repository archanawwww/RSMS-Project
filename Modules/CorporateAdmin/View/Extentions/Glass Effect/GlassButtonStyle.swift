//
//  GlassButtonStyle.swift
//  Auth Management
//
//  Created by Shivraj Pun on 26/06/26.
//
import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassEffect(
                .regular.interactive(configuration.isPressed),
                in: Capsule()
            )
            .scaleEffect(configuration.isPressed ? 0.70 : 1.0)
            .animation(.smooth(duration: 0.15), value: configuration.isPressed)
    }
}
