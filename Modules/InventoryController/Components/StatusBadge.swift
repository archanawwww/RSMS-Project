import SwiftUI

struct StatusBadge: View {
    let status: String
    
    var color: Color {
        switch status.lowercased() {
        case "pending": return Color.theme.pending
        case "approved": return Color.theme.approved
        case "rejected": return Color.theme.rejected
        case "fulfilled": return Color.theme.fulfilled
        case "dispatched": return Color.theme.dispatched
        case "in transit": return Color.theme.inTransit
        case "received": return Color.theme.approved
        case "open": return Color.theme.information
        default: return Color.gray
        }
    }
    
    var body: some View {
        Text(status.uppercased())
            .font(Typography.metadata.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .cornerRadius(Spacing.chipRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.chipRadius)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
    }
}
