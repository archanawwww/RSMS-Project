import SwiftUI

public enum MatteTheme {
    // MARK: - iOS 26 Liquid Glass Spacing System (8pt grid)
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
        
        public static let horizontalMargin: CGFloat = 20
        public static let cardPadding: CGFloat = 20
        public static let sectionSpacing: CGFloat = 16
        public static let elementSpacing: CGFloat = 12
    }
    
    // MARK: - iOS 26 Liquid Glass Typography
    public enum Typography {
        public static let pageTitle = Font.system(size: 34, weight: .bold, design: .default)
        public static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
        public static let title = Font.system(size: 24, weight: .bold, design: .default)
        public static let sectionHeader = Font.system(size: 20, weight: .semibold, design: .default)
        public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        public static let body = Font.system(size: 17, weight: .regular, design: .default)
        public static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        public static let callout = Font.system(size: 16, weight: .regular, design: .default)
        public static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        public static let caption = Font.system(size: 12, weight: .regular, design: .default)
        public static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        public static let kpiValue = Font.system(size: 20, weight: .bold, design: .monospaced)
        public static let metricLabel = Font.system(size: 10, weight: .medium, design: .default)
    }
    
    // MARK: - iOS 26 Liquid Glass Corner Radius
    public enum CornerRadius {
        public static let small: CGFloat = 12
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 20
        public static let xlarge: CGFloat = 24
        public static let capsule: CGFloat = 1000
    }
    
    // MARK: - iOS 26 Liquid Glass Colors
    public enum Colors {
        // Soft neutral palette - Premium Apple-inspired
        public static let primaryBackground = Color(red: 248/255, green: 246/255, blue: 242/255) // #F8F6F2
        public static let loginBackground = Color(red: 245/255, green: 242/255, blue: 237/255) // #F5F2ED
        public static let dashboardBackground = Color(red: 250/255, green: 248/255, blue: 245/255) // #FAF8F5
        public static let secondaryBackground = Color(red: 252/255, green: 250/255, blue: 247/255) // #FCFAF7
        public static let surface = Color.white // #FFFFFF
        
        // Glass borders - subtle and refined
        public static let border = Color(red: 228/255, green: 224/255, blue: 218/255) // #E4E0DA
        public static let borderLight = Color(red: 235/255, green: 231/255, blue: 226/255) // #EBE7E2
        
        // Subtle accents
        public static let subtleAccent = Color(red: 242/255, green: 238/255, blue: 232/255) // #F2EEE8
        public static let glassOverlay = Color.white.opacity(0.72)
        public static let glassBackground = Color.white.opacity(0.85)
        
        // Text hierarchy - High contrast for accessibility
        public static let textPrimary = Color(red: 28/255, green: 27/255, blue: 26/255) // #1C1B1A
        public static let textSecondary = Color(red: 99/255, green: 95/255, blue: 90/255) // #635F5A
        public static let textTertiary = Color(red: 142/255, green: 137/255, blue: 131/255) // #8E8983
        
        // Accent color - Used sparingly
        public static let accent = Color(red: 180/255, green: 130/255, blue: 8/255) // #B48208
        public static let accentLight = Color(red: 245/255, green: 235/255, blue: 210/255) // #F5EBD2
        
        // Status colors - Refined and accessible
        public static let success = Color(red: 40/255, green: 120/255, blue: 45/255) // #28782D
        public static let successLight = Color(red: 220/255, green: 245/255, blue: 222/255) // #DCF5DE
        public static let warning = Color(red: 230/255, green: 155/255, blue: 30/255) // #E69B1E
        public static let warningLight = Color(red: 255/255, green: 245/255, blue: 230/255) // #FFF5E6
        public static let error = Color(red: 215/255, green: 50/255, blue: 45/255) // #D7322D
        public static let errorLight = Color(red: 255/255, green: 235/255, blue: 233/255) // #FFEBE9
        public static let info = Color(red: 50/255, green: 85/255, blue: 170/255) // #3255AA
        public static let infoLight = Color(red: 235/255, green: 242/255, blue: 255/255) // #EBF2FF
        
        // Legacy color names for compatibility
        public static let primaryGold = accent
        public static let goldLight = accentLight
        public static let sandstone = subtleAccent
        public static let warmClay = textSecondary
        public static let burntSienna = accent
        public static let ivoryMatte = secondaryBackground
        public static let espresso = textPrimary
        public static let goldenAmber = accent
        public static let fogGlass = glassBackground
        
        // Premium Luxury Palette — iOS 26 Redesign
        public static let luxuryGold = Color(red: 197/255, green: 165/255, blue: 90/255)   // #C5A55A
        public static let deepBlack = Color(red: 13/255, green: 13/255, blue: 13/255)       // #0D0D0D
        public static let ivory = Color(red: 254/255, green: 252/255, blue: 246/255)        // #FEFCF6
        public static let notificationBadge = Color(red: 235/255, green: 64/255, blue: 52/255)  // #EB4034
        public static let chartGold = Color(red: 212/255, green: 175/255, blue: 85/255)     // #D4AF55
        public static let sectionDivider = Color(red: 240/255, green: 237/255, blue: 232/255) // #F0EDE8

        
        public static func roleColor(for role: UserRole) -> Color {
            switch role {
            case .boutiqueManager: return accent
            case .salesAssociate: return success
            case .corporateAdmin: return textPrimary
            case .inventoryController: return info
            }
        }
    }
}

// MARK: - iOS 26 Liquid Glass Components

public struct LiquidGlassCard: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.xlarge))
    }
}

public struct MatteSurfaceCard: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.xlarge))
    }
}

public struct LiquidGlassSectionCard: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(MatteTheme.Spacing.cardPadding)
            .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.large))
    }
}

public struct MatteImageBackground: ViewModifier {
    let imageName: String

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    MatteTheme.Colors.primaryBackground

                    GeometryReader { proxy in
                        Image(imageName)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .opacity(0.58)
                    }

                    MatteTheme.Colors.primaryBackground.opacity(0.38)
                }
                .ignoresSafeArea()
            }
    }
}

public extension View {
    func liquidGlassCard() -> some View {
        modifier(LiquidGlassCard())
    }

    func matteSurfaceCard() -> some View {
        modifier(MatteSurfaceCard())
    }
    
    func liquidGlassSectionCard() -> some View {
        modifier(LiquidGlassSectionCard())
    }

    func matteImageBackground(_ imageName: String) -> some View {
        modifier(MatteImageBackground(imageName: imageName))
    }
}

// MARK: - iOS 26 Liquid Glass Button

public struct LiquidGlassButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var style: ButtonStyle = .primary
    
    public enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    public var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            action()
        }) {
            ZStack {
                Text(title)
                    .font(MatteTheme.Typography.headline)
                    .foregroundColor(buttonTextColor)
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: buttonTextColor))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(buttonBackground)
            .cornerRadius(MatteTheme.CornerRadius.capsule)
            .overlay(
                Capsule()
                    .stroke(buttonBorderColor, lineWidth: 1)
            )
            .shadow(color: MatteTheme.Colors.textPrimary.opacity(0.1), radius: 12, x: 0, y: 4)
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
    
    private var buttonTextColor: Color {
        switch style {
        case .primary: return MatteTheme.Colors.surface
        case .secondary: return MatteTheme.Colors.textPrimary
        case .destructive: return MatteTheme.Colors.surface
        }
    }
    
    private var buttonBackground: Color {
        switch style {
        case .primary: return MatteTheme.Colors.textPrimary
        case .secondary: return MatteTheme.Colors.surface
        case .destructive: return MatteTheme.Colors.error
        }
    }
    
    private var buttonBorderColor: Color {
        switch style {
        case .primary: return Color.clear
        case .secondary: return MatteTheme.Colors.border
        case .destructive: return Color.clear
        }
    }
}

// MARK: - iOS 26 Liquid Glass Text Field

public struct LiquidGlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var textContentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    
    @FocusState private var isFocused: Bool
    
    public var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(textContentType)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding(.horizontal, MatteTheme.Spacing.md)
        .padding(.vertical, MatteTheme.Spacing.sm)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(MatteTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.medium)
                .stroke(isFocused ? MatteTheme.Colors.accent : MatteTheme.Colors.border, lineWidth: 1)
        )
        .foregroundColor(MatteTheme.Colors.textPrimary)
        .font(MatteTheme.Typography.body)
        .accentColor(MatteTheme.Colors.accent)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Legacy Components (for compatibility)

public struct MatteButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    public var body: some View {
        LiquidGlassButton(title: title, action: action, isLoading: isLoading)
    }
}

public struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var textContentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    
    public var body: some View {
        LiquidGlassTextField(
            placeholder: placeholder,
            text: $text,
            isSecure: isSecure,
            textContentType: textContentType,
            keyboardType: keyboardType
        )
    }
}
