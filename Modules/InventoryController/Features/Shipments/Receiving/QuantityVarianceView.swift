import SwiftUI

struct QuantityVarianceView: View {
    let session: ReceivingSession
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: ShipmentsViewModel
    @State private var navigateToReview = false
    @State private var showConfirmation = false
    @State private var showSuccessOverlay = false
    
    var hasVariances: Bool {
        session.asn.items.contains { $0.expectedQuantity != $0.receivedQuantity }
    }
    
    var discrepantItems: [ASNItem] {
        session.asn.items.filter { $0.expectedQuantity != $0.receivedQuantity }
    }
    
    var body: some View {
        List {
            Section("Shipment Information") {
                LabeledContent("ASN", value: session.asn.id.uuidString)
                LabeledContent("Vendor", value: session.asn.vendorName)
                LabeledContent("Warehouse", value: "WH-01 Central Warehouse")
                LabeledContent("Received", value: Date().formatted(date: .abbreviated, time: .omitted))
                
                HStack {
                    Text("Status")
                    Spacer()
                    if hasVariances {
                        Label("Variance Detected", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(hex: "#B9823A"))
                            .font(.subheadline.weight(.semibold))
                    } else {
                        Label("Verified", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
            
            Section("Receiving Summary") {
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
                .padding(.vertical, 8)
            }
            
            if hasVariances {
                Section("Items Requiring Attention (\(discrepantItems.count))") {
                    ForEach(discrepantItems) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "shippingbox")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#B9823A"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.productName)
                                    .font(.headline)
                                Text("SKU: \(item.sku)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 16) {
                                    Text("Exp: \(item.expectedQuantity)")
                                    Text("Rec: \(item.receivedQuantity)")
                                    let v = item.receivedQuantity - item.expectedQuantity
                                    Text("Var: \(v > 0 ? "+" : "")\(v)")
                                        .foregroundColor(v == 0 ? .primary : Color(hex: "#B9823A"))
                                        .fontWeight(.bold)
                                }
                                .font(.caption)
                                .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Receiving Summary")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if hasVariances {
                    Button {
                        navigateToReview = true
                    } label: {
                        Text("Complete with Variance")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#B9823A"))
                    .controlSize(.large)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Re-verify Scans")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(hex: "#2C2A28"))
                    .controlSize(.large)
                } else {
                    Button {
                        showConfirmation = true
                    } label: {
                        Text("Complete Receiving")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#B9823A"))
                    .controlSize(.large)
                    .alert("Complete Receiving?", isPresented: $showConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Complete Receiving", role: .destructive) {

                            Task {

                                await viewModel.completeShipment(
                                    id: session.asn.shipmentId,
                                    hasVariance: false
                                )
                                
                                try? await ShipmentRepository()
                                    .updateReceivedTime(
                                        shipmentId: session.asn.shipmentId
                                    )

                                withAnimation {
                                    showSuccessOverlay = true
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    NotificationCenter.default.post(
                                        name: NSNotification.Name("PopToRoot"),
                                        object: nil
                                    )
                                }
                            }

                        }
                    } message: {
                        Text("The receiving session will be completed.\nThe ASN will be closed.\nThis action cannot be undone.")
                    }
                }
            }
            .padding(20)
            .background(.bar)
        }
        .background(Color(hex: "#FAF8F4"))
        .overlay {
            if showSuccessOverlay {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.green, lineWidth: 3)
                                .frame(width: 60, height: 60)
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        Text("Receiving Completed")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("ASN \(session.asn.id.uuidString) has been successfully closed.\nInventory records updated.\nVariance report generated.")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .padding(40)
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Receiving Summary")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(Color.theme.background.ignoresSafeArea())
        .navigationDestination(isPresented: $navigateToReview) {
            ConfirmVarianceCompletionView(session: session)
        }
    }
}

#Preview {
    let mockASN = ASN(
        id: UUID(),
        shipmentId: "SHP-250528-001",
        vendorName: "Rolex Distribution SA",
        expectedDate: Date(),
        status: "Pending",
        totalExpected: 10,
        totalReceived: 8,
        createdAt: Date(),
        items: [
            ASNItem(
                id: UUID(),
                asnId: UUID().uuidString,
                productId: nil,
                sku: "RLX-DAY-001",
                productName: "Rolex Daytona",
                productImageURL: "",
                expectedQuantity: 10,
                receivedQuantity: 8
            )
        ]
    )
    
    NavigationStack {
        QuantityVarianceView(session: ReceivingSession(asn: mockASN))
            .environmentObject(ShipmentsViewModel())
    }
}
