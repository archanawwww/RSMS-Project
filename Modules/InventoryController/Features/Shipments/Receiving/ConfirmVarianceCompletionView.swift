import SwiftUI

struct ConfirmVarianceCompletionView: View {
    let session: ReceivingSession
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: ShipmentsViewModel
    
    @State private var navigateToProcessing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: "#B9823A"))
                    
                    Text("Complete Shipment\nwith Variance")
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Completing this shipment will:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Update inventory using the verified quantities.", systemImage: "circle.fill")
                            .labelStyle(BulletLabelStyle())
                        Label("Mark this shipment as Received with Variance.", systemImage: "circle.fill")
                            .labelStyle(BulletLabelStyle())
                        Label("Create an immutable audit record.", systemImage: "circle.fill")
                            .labelStyle(BulletLabelStyle())
                        Label("Require a discrepancy report before manager review.", systemImage: "circle.fill")
                            .labelStyle(BulletLabelStyle())
                    }
                    .font(.body)
                }
                .padding(.horizontal)
                
                // Variance Summary Box
                HStack {
                    VStack(alignment: .center) {
                        Text("Expected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(session.asn.totalExpected)")
                            .font(.title2.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .center) {
                        Text("Received")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(session.asn.totalReceived)")
                            .font(.title2.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .center) {
                        Text("Variance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let variance = session.asn.totalReceived - session.asn.totalExpected
                        Text("\(variance > 0 ? "+" : "")\(variance)")
                            .font(.title2.weight(.bold))
                            .foregroundColor(variance == 0 ? .primary : Color(hex: "#B9823A"))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                VStack(spacing: 16) {
                    Button {
                        navigateToProcessing = true
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#B9823A"))
                    .controlSize(.large)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(hex: "#2C2A28"))
                    .controlSize(.large)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(Color(hex: "#FAF8F4"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToProcessing) {
            ReportDiscrepancyView(session: session)
        }
    }
}

struct BulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 10) {
            configuration.icon
                .font(.system(size: 6))
                .padding(.top, 7)
                .foregroundColor(Color(hex: "#B9823A"))
            configuration.title
        }
    }
}

#Preview {
    let mockASN = ASN(
        id: UUID(),
        shipmentId: "SHP-001",
        vendorName: "Rolex Distribution SA",
        expectedDate: Date(),
        status: "inTransit",
        totalExpected: 10,
        totalReceived: 8,
        createdAt: Date(),
        items: [
            ASNItem(id: UUID(), asnId: "ASN-1024", productId: nil, sku: "RLX-DAY-001", productName: "Rolex Daytona", productImageURL: nil, expectedQuantity: 10, receivedQuantity: 8)
        ]
    )
    
    NavigationStack {
        ConfirmVarianceCompletionView(session: ReceivingSession(asn: mockASN))
            .environmentObject(ShipmentsViewModel())
    }
}
