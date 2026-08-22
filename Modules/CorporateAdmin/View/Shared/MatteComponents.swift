import SwiftUI

// MARK: - Matte Panel (iOS 26 Liquid Glass)

extension View {

    func mattePanel() -> some View {
        self
            .padding(MatteTheme.Spacing.cardPadding)
            .background(MatteTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.large)
                    .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
            )
            .shadow(color: MatteTheme.Colors.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }

}

// MARK: - Primary Button (iOS 26 Liquid Glass)

struct MattePrimaryButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MatteTheme.Typography.headline)
            .foregroundColor(MatteTheme.Colors.surface)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                configuration.isPressed
                ? MatteTheme.Colors.textPrimary.opacity(0.7)
                : MatteTheme.Colors.textPrimary
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }

}
