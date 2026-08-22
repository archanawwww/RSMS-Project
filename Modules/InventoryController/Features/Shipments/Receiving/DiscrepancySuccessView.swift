import SwiftUI

struct DiscrepancySuccessView: View {
    let session: ReceivingSession
    
    @State private var navigateToException = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header Content
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(hex: "#B9823A"))
                
                VStack(spacing: 8) {
                    Text("Discrepancy Recorded")
                        .font(.title2.weight(.bold))
                    
                    Text("Shipment completed with variance.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
            
            // Summary List
            List {
                Section {
                    LabeledContent("Shipment", value: session.asn.id.uuidString)
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Label("Received with Variance", systemImage: "checkmark.circle")
                            .foregroundColor(Color(hex: "#B9823A"))
                    }
                    
                    LabeledContent("Exception ID", value: "EXC-2026-00142")
                    
                    HStack {
                        Text("Audit Trail")
                        Spacer()
                        Label("Recorded", systemImage: "checkmark.circle")
                            .foregroundColor(Color(hex: "#B9823A"))
                    }
                    
                    HStack {
                        Text("Manager Review")
                        Spacer()
                        Label("Pending", systemImage: "clock")
                            .foregroundColor(Color(hex: "#B9823A"))
                    }
                    
                    HStack {
                        Text("Inventory")
                        Spacer()
                        Label("Updated", systemImage: "shippingbox")
                            .foregroundColor(.primary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDisabled(true)
            
            // Bottom Actions
            VStack(spacing: 12) {
                Button {
                    NotificationCenter.default.post(name: NSNotification.Name("PopToRoot"), object: nil)
                } label: {
                    Text("Return to Shipments")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#B9823A"))
                .controlSize(.large)
                
                Button {
                    navigateToException = true
                } label: {
                    Text("View Exception Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(Color(hex: "#2C2A28"))
                .controlSize(.large)
            }
            .padding(20)
            .background(.bar)
        }
        .background(Color(hex: "#FAF8F4"))
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToException) {
            ExceptionDetailsView(session: session)
        }
    }
}

#Preview {
    NavigationStack {
        let mockSession = ReceivingSession(
            asn: ASN(
                id: UUID(),
                shipmentId: "SHP-123",
                vendorName: "Acme Corp",
                expectedDate: Date(),
                status: "Pending",
                totalExpected: 0,
                totalReceived: 0,
                createdAt: Date(),
                items: []
            )
        )
        DiscrepancySuccessView(session: mockSession)
    }
}
