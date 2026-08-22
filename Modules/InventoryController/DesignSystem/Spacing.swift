import Foundation

struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let space40: CGFloat = 40
    static let space48: CGFloat = 48
    static let space64: CGFloat = 64
    
    // Legacy support
    static let small: CGFloat = 8
    static let standard: CGFloat = 16
    static let medium: CGFloat = 24
    static let large: CGFloat = 32
    static let xlarge: CGFloat = 40

    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 12
    static let searchRadius: CGFloat = 12
    static let imageRadius: CGFloat = 10
    static let sheetRadius: CGFloat = 24
    static let chipRadius: CGFloat = 20

    struct Shadow {
        static let opacity: Double = 0.06
        static let radius: CGFloat = 12
        static let yOffset: CGFloat = 4
    }
}
