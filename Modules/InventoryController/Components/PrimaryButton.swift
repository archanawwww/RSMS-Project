import SwiftUI

enum ButtonStyleType {
    case primary
    case secondary
    case tertiary
    case destructive
}

struct PrimaryButton: View {
    let title: String
    var style: ButtonStyleType = .primary
    let action: () -> Void
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.theme.brand
        case .secondary: return Color.white
        case .tertiary: return Color.clear
        case .destructive: return Color.theme.critical
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return Color.theme.textPrimary
        case .tertiary: return Color.theme.brand
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(Spacing.buttonRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.buttonRadius)
                        .stroke(style == .secondary ? Color.theme.border : Color.clear, lineWidth: 1)
                )
        }
    }
}
