import SwiftUI

struct ReceivingCompleteView: View {
    let session: ReceivingSession
    
    // For demo purposes. In real app, this logic belongs to ViewModel
    var requiresCycleCountPrompt: Bool {
        return true
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .stroke(Color.green, lineWidth: 4)
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                Text("Receiving Complete")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.green)
                
                Text("\(session.asn.totalReceived) / \(session.asn.totalExpected)")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(Color.theme.textPrimary)
                    .padding(.top, 8)
                
                if session.asn.totalReceived == session.asn.totalExpected {
                    Text("All ASN items matched successfully.")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                } else {
                    Text("Receiving completed with variances.")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                    Text("ASN Closed")
                        .font(.system(size: 15, weight: .medium, design: .default))
                }
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                    Text("Inventory Updated")
                        .font(.system(size: 15, weight: .medium, design: .default))
                }
            }
            .padding(.top, 24)
            
            Spacer()
            
            if requiresCycleCountPrompt {
                NavigationLink(value: AppDestination.optionalVerification("RLX-DAY-001")) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#B9823A"))
                .controlSize(.large)
            } else {
                Button {
                    NotificationCenter.default.post(name: NSNotification.Name("PopToRoot"), object: nil)
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#B9823A"))
                .controlSize(.large)
            }
        }
        .padding(24)
        .navigationBarHidden(true)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    ReceivingCompleteView(session: ReceivingSession(
        asn: ASN(
            id: UUID(),
            shipmentId: "SHP-123",
            vendorName: "Acme",
            expectedDate: Date(),
            status: "Pending",
            totalExpected: 0,
            totalReceived: 0,
            createdAt: Date(),
            items: []
        )
    ))
}
