import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let theme = ColorTheme()
}

struct ColorTheme {
    // Screen background — Primary Background
    let background = Color(hex: "#FDFBF8")
    // Grouped background
    let backgroundGrouped = Color(hex: "#F3EFEA")
    // Secondary background
    let backgroundSecondary = Color(hex: "#F8F5F1")

    // Card surface
    let surface = Color.white
    let surfaceSelected = Color(hex: "#FBF7F2")

    // Borders
    let border = Color(hex: "#ECE6DF")
    let cardBorder = Color(hex: "#EEE7DF")

    // Text Colors
    let textPrimary = Color(hex: "#1E1E1E")
    let textSecondary = Color(hex: "#666666")
    let textTertiary = Color(hex: "#9A9A9A")
    let textDisabled = Color(hex: "#C5C5C5")

    let accent = Color(hex: "#AB793D")
    let brand = Color(hex: "#AB793D") // Luxury Gold

    // Semantic Status Colors (muted enterprise tones)
    let success = Color(hex: "#5E8E63")
    let warning = Color(hex: "#D9A441")
    let error = Color(hex: "#D96B5F")
    let information = Color(hex: "#5D7E9B")
    let critical = Color(hex: "#D96B5F")

    // Workflow accent colors (mapping to semantic/brand)
    let workflowPurple = Color(hex: "#AB793D") // Map to brand
    let workflowOrange = Color(hex: "#D9A441") // Map to warning
    let workflowGreen = Color(hex: "#5E8E63")  // Map to success
    let workflowBlue = Color(hex: "#5D7E9B")   // Map to info

    // Status colors (legacy support for existing code)
    let pending = Color(hex: "#D9A441") // warning
    let approved = Color(hex: "#5E8E63") // success
    let rejected = Color(hex: "#D96B5F") // error
    let fulfilled = Color(hex: "#5E8E63") // success
    let dispatched = Color(hex: "#5D7E9B") // info
    let inTransit = Color(hex: "#5D7E9B") // info

    // Status Chips
    struct StatusChipColors {
        let background: Color
        let text: Color
        let border: Color
    }

    let statusActive = StatusChipColors(background: Color(hex: "#AB793D"), text: .white, border: Color(hex: "#AB793D"))
    let statusInactive = StatusChipColors(background: Color(hex: "#F5F2EE"), text: Color(hex: "#666666"), border: Color(hex: "#F5F2EE"))
}
