import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(Typography.title)
                .foregroundColor(Color.theme.textPrimary)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Typography.subheadline)
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .padding(.vertical, Spacing.small)
    }
}
