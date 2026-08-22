import SwiftUI

struct OptionalVerificationView: View {
    let sku: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .stroke(Color(hex: "#B9823A"), lineWidth: 4)
                    .frame(width: 100, height: 100)
                Image(systemName: "clipboard")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundColor(Color(hex: "#B9823A"))
            }
            
            VStack(spacing: 16) {
                Text("Inventory Updated")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text("This shipment replenished a low-stock SKU. A verification count is recommended to ensure on-hand accuracy.")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    // Navigate to IC-05 Cycle Count (Future Scope)
                }) {
                    Text("Verify Inventory")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.theme.accent)
                        .cornerRadius(14)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.theme.textSecondary)
                    Text("Recommended for low-stock replenishments")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.bottom, 8)
                
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("PopToRoot"), object: nil)
                }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)
                }
            }
        }
        .padding(24)
        .navigationBarHidden(true)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    OptionalVerificationView(sku: "RLX-123")
}
