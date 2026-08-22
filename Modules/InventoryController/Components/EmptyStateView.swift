import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let message: String
    var description: String? = nil
    
    var body: some View {
        VStack(spacing: Spacing.standard) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(Color.theme.textTertiary)
            
            Text(message)
                .font(Typography.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            if let description = description {
                Text(description)
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
