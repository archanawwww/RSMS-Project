import SwiftUI

struct ExceptionDetailsView: View {
    let session: ReceivingSession
    @Environment(\.dismiss) private var dismiss
    
    var discrepantItems: [ASNItem] {
        session.asn.items.filter { $0.expectedQuantity != $0.receivedQuantity }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        StatusBadge(status: "Open")
                        
                        Spacer()
                        
                        Text("VAR-\(Int.random(in: 2025...2025))-\(Int.random(in: 1000...9999))")
                            .font(.system(.subheadline, design: .default).weight(.semibold))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        detailRow(title: "ASN", value: session.asn.id.uuidString)
                        detailRow(title: "Vendor", value: session.asn.vendorName)
                        detailRow(title: "Warehouse", value: "WH-01")
                        detailRow(title: "Created On", value: Date().formatted(date: .abbreviated, time: .shortened))
                        detailRow(title: "Created By", value: "John Smith")
                        detailRow(title: "Status", value: "Open", isStatus: true)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(12)
                
                // Affected Items
                VStack(alignment: .leading, spacing: 12) {
                    Text("Items (\(discrepantItems.count))")
                        .font(.system(.headline, design: .default).weight(.bold))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(discrepantItems.enumerated()), id: \.element.id) { index, item in
                            let variance = item.receivedQuantity - item.expectedQuantity
                            
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "shippingbox")
                                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.productName)
                                            .font(.system(.headline, design: .default).weight(.semibold))
                                        Text("SKU: \(item.sku)")
                                            .font(.system(.subheadline, design: .default))
                                            .foregroundColor(Color.theme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                }
                                
                                HStack {
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Expected")
                                            .font(.system(.caption, design: .default).weight(.medium))
                                            .foregroundColor(Color.theme.textSecondary)
                                        Text("\(item.expectedQuantity)")
                                            .font(.system(.title3, design: .default).weight(.bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Divider().frame(height: 32)
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Received")
                                            .font(.system(.caption, design: .default).weight(.medium))
                                            .foregroundColor(Color.theme.textSecondary)
                                        Text("\(item.receivedQuantity)")
                                            .font(.system(.title3, design: .default).weight(.bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Divider().frame(height: 32)
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Variance")
                                            .font(.system(.caption, design: .default).weight(.medium))
                                            .foregroundColor(Color.theme.textSecondary)
                                        Text("\(variance > 0 ? "+" : "")\(variance)")
                                            .font(.system(.title2, design: .default).weight(.bold))
                                            .foregroundColor(variance == 0 ? .green : .red)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            
                            if index < discrepantItems.count - 1 {
                                Divider().padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Timeline
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity Timeline")
                        .font(.system(.headline, design: .default).weight(.bold))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        timelineItem(icon: "checkmark.circle.fill", color: .green, title: Date().formatted(date: .abbreviated, time: .shortened), subtitle: "Discrepancy reported and exception created", isLast: false)
                        timelineItem(icon: "checkmark.circle.fill", color: .green, title: Date().formatted(date: .abbreviated, time: .shortened), subtitle: "Inventory quarantined securely", isLast: false)
                        timelineItem(icon: "circle", color: Color(UIColor.systemGray3), title: "Vendor Reviewing", subtitle: "Awaiting vendor response", isLast: false)
                        timelineItem(icon: "circle", color: Color(UIColor.systemGray3), title: "Resolution Pending", subtitle: "", isLast: false)
                        timelineItem(icon: "circle", color: Color(UIColor.systemGray3), title: "Closed", subtitle: "", isLast: true)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Audit Information Footer
                VStack(spacing: 8) {
                    Text("IMMUTABLE AUDIT RECORD")
                        .font(.system(.caption, design: .default).weight(.bold))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Text("Created By: Rahul Sharma\nCreated On: \(Date().formatted())\nLast Updated: \(Date().formatted())")
                        .font(.system(.caption, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
            }
            .padding(20)
        }
        .appScreen()
        .navigationTitle("Variance Case Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func detailRow(title: String, value: String, isStatus: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(.subheadline, design: .default).weight(.medium))
                .foregroundColor(Color.theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .default).weight(isStatus ? .bold : .semibold))
                .foregroundColor(isStatus ? .blue : Color.theme.textPrimary)
        }
    }
    
    private func timelineItem(icon: String, color: Color, title: String, subtitle: String, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(Color.white)
                    .zIndex(1)
                
                if !isLast {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: 2)
                        .frame(maxHeight: subtitle.isEmpty ? 24 : 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .default).weight(.semibold))
                    .foregroundColor(color == Color(UIColor.systemGray3) ? Color.theme.textSecondary : Color.theme.textPrimary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(.caption, design: .default))
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
            .padding(.top, 2)
            .padding(.bottom, isLast ? 0 : 20)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ExceptionDetailsView(session: ReceivingSession(
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
        ))
    }
}
