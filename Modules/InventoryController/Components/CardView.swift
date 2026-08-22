import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.lg)
            .background(Color.theme.surface)
            .cornerRadius(Spacing.cardRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(Spacing.Shadow.opacity),
                radius: Spacing.Shadow.radius,
                x: 0,
                y: Spacing.Shadow.yOffset
            )
    }
}
