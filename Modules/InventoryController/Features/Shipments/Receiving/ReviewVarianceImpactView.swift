import SwiftUI

struct ReviewVarianceImpactView: View {
    let session: ReceivingSession
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToConfirm = false
    
    var body: some View {
        ZStack {
            Color(hex: "#FDFBF8").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.asn.id.uuidString)
                                    .font(.system(.title3, design: .default).weight(.bold))
                                Text(session.asn.vendorName)
                                    .font(.system(.subheadline, design: .default))
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            Spacer()
                            Text("Partially Received")
                                .font(.system(.caption, design: .default).weight(.semibold))
                                .foregroundColor(Color.theme.warning)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.theme.warning.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Distribution Centre")
                                    .font(.system(.caption, design: .default).weight(.medium))
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("Delhi DC")
                                    .font(.system(.subheadline, design: .default).weight(.medium))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Received On")
                                    .font(.system(.caption, design: .default).weight(.medium))
                                    .foregroundColor(Color.theme.textSecondary)
                                Text(Date().formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(.subheadline, design: .default).weight(.medium))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Variance Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Variance Summary")
                            .font(.system(.headline, design: .default).weight(.bold))
                        
                        HStack {
                            VStack(alignment: .center, spacing: 4) {
                                Text("Expected")
                                    .font(.system(.caption, design: .default).weight(.medium))
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("\(session.asn.totalExpected)")
                                    .font(.system(.title3, design: .default).weight(.bold))
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .center, spacing: 4) {
                                Text("Received")
                                    .font(.system(.caption, design: .default).weight(.medium))
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("\(session.asn.totalReceived)")
                                    .font(.system(.title3, design: .default).weight(.bold))
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .center, spacing: 4) {
                                Text("Variance")
                                    .font(.system(.caption, design: .default).weight(.medium))
                                    .foregroundColor(Color.theme.textSecondary)
                                let variance = session.asn.totalReceived - session.asn.totalExpected
                                Text("\(variance > 0 ? "+" : "")\(variance)")
                                    .font(.system(.title2, design: .default).weight(.bold))
                                    .foregroundColor(variance == 0 ? .green : .red)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Actions that will occur
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Actions that will occur")
                            .font(.system(.headline, design: .default).weight(.bold))
                        
                        VStack(alignment: .leading, spacing: 16) {
                            actionRow(icon: "archivebox", text: "Inventory will be updated with the actual received quantities.")
                            actionRow(icon: "doc.text", text: "Shipment will be marked as Received with Variance.")
                            actionRow(icon: "lock.doc", text: "An immutable audit record will be created.")
                            actionRow(icon: "folder.badge.plus", text: "Variance case will be created for tracking and review.")
                            actionRow(icon: "bell", text: "Managers will be notified if variance exceeds the configured threshold.")
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    VStack(spacing: 12) {
                        Button {
                            navigateToConfirm = true
                        } label: {
                            Text("Continue")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "#AB793D"))
                        .controlSize(.large)
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
        }
        .navigationTitle("Review Variance Impact")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToConfirm) {
            ConfirmVarianceCompletionView(session: session)
        }
    }
    
    private func actionRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "#AB793D"))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundColor(Color.theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    let mockASN = ASN(
        id: UUID(),
        shipmentId: "SHP-001",
        vendorName: "Richmond Supply Ltd.",
        expectedDate: Date(),
        status: "Pending",
        totalExpected: 15,
        totalReceived: 13,
        createdAt: Date(),
        items: [
            ASNItem(id: UUID(), asnId: "ASN-1024", productId: nil, sku: "RLX-DAY-001", productName: "Rolex Daytona", productImageURL: nil, expectedQuantity: 10, receivedQuantity: 8),
            ASNItem(id: UUID(), asnId: "ASN-1024", productId: nil, sku: "CRT-TNK-002", productName: "Cartier Tank", productImageURL: nil, expectedQuantity: 5, receivedQuantity: 5)
        ]
    )
    let mockSession = ReceivingSession(asn: mockASN)
    
    NavigationStack {
        ReviewVarianceImpactView(session: mockSession)
    }
}
