import SwiftUI

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.theme.success.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.theme.success)
            }
            
            VStack(spacing: 12) {
                Text("Count Complete")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text("Inventory has been updated and variances recorded.")
                    .font(.system(size: 16))
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button {
                // Navigate back to root
                NotificationCenter.default.post(name: NSNotification.Name("ReturnToRoot"), object: nil)
            } label: {
                Text("Back to Dashboard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.theme.brand)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(16)
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}
