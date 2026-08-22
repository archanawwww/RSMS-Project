import SwiftUI

public struct BadgeView: View {

    private let text: String
    private let color: Color

    public init(
        _ text: String,
        color: Color = .blue
    ) {
        self.text = text
        self.color = color
    }

    public init(
        text: String,
        color: Color = .blue
    ) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        BadgeView("Corporate")
        BadgeView("Approved", color: .green)
        BadgeView(text: "Pending", color: .orange)
        BadgeView(text: "Rejected", color: .red)
    }
    .padding()
}
