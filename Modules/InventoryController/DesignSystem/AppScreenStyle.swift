import SwiftUI

struct AppScreenStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.theme.background.ignoresSafeArea())
    }
}

extension View {
    /// Applies the global app screen style:
    /// - Inline navigation bar title
    /// - Standard global background color (#FDFBF8) ignoring safe area
    func appScreen() -> some View {
        self.modifier(AppScreenStyle())
    }
}
