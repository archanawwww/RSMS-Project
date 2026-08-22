import SwiftUI

struct InventoryAdjustmentRecord: Identifiable {
    let id             = UUID()
    let cycleCountId:   UUID
    let sessionName:    String
    let productName:    String
    let sku:            String
    let expected:       Int
    let counted:        Int
    let difference:     Int
    let adjustmentType: String
    let reason:         String
    let notes:          String?
    let timestamp:      Date
}

struct ReviewInventoryDifferencesSheet: View {
    let session: CycleCountSession
    let varianceItems: [CycleCountItem]
    let onComplete: ([InventoryAdjustmentRecord]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // In a real app we'd load prices. We'll mock price to calculate variance value.
    private var totalVarianceValue: Double {
        varianceItems.reduce(0.0) { sum, item in
            let expected = item.expectedQuantity
            let counted = item.countedQuantity
            let diff = counted - expected
            return sum + (Double(diff) * (item.basePrice ?? 0.0))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // ── Summary Card ──────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(session.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.theme.textPrimary)
                            Spacer()
                            Text("Pending Approval")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.theme.brand)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.theme.brand.opacity(0.1))
                                .overlay(Capsule().stroke(Color.theme.brand.opacity(0.2), lineWidth: 1))
                                .clipShape(Capsule())
                        }
                        
                        Text(session.location ?? "High Value Storage")
                            .font(.system(size: 14))
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Divider().background(Color.theme.border)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Items Counted")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textSecondary)
                                Spacer()
                                Text("\(session.total)") // Mocked total
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            
                            HStack {
                                Text("No Variance")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textSecondary)
                                Spacer()
                                HStack(spacing: 6) {
                                    Text("\(session.total - varianceItems.count)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.theme.textPrimary)
                                    Circle().fill(Color.theme.success).frame(width: 8, height: 8)
                                }
                            }
                            
                            HStack {
                                Text("With Variance")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textSecondary)
                                Spacer()
                                HStack(spacing: 6) {
                                    Text("\(varianceItems.count)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.theme.textPrimary)
                                    Circle().fill(Color.theme.brand).frame(width: 8, height: 8)
                                }
                            }
                            
                            if totalVarianceValue != 0 {
                                HStack {
                                    Text("Total Variance Value")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.theme.textSecondary)
                                    Spacer()
                                    Text(String(format: "%@$%.2f", totalVarianceValue < 0 ? "-" : "+", abs(totalVarianceValue)))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color.theme.brand)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                    .padding(.horizontal, 16)
                    
                    // ── Items with Variance ────────────────────────────────────
                    if !varianceItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Items with Variance")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.theme.textPrimary)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(varianceItems.enumerated()), id: \.element.id) { index, item in
                                    let expected = item.expectedQuantity
                                    let counted = item.countedQuantity
                                    let diff = counted - expected
                                    
                                    HStack(spacing: 12) {
                                        InventoryProductThumbnail(imageUrl: item.imageUrl, category: item.category, size: 40)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color.theme.textPrimary)
                                            Text(item.sku)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.theme.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(diff > 0 ? "+\(diff)" : "\(diff)")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color.theme.brand)
                                            Text("Counted: \(counted)")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.theme.textSecondary)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    
                                    if index < varianceItems.count - 1 {
                                        Divider().padding(.leading, 68)
                                    }
                                }
                            }
                            .background(Color.theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                            .padding(.horizontal, 16)
                        }
                    }
                    
                }
                .padding(.vertical, 24)
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Variance Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color.theme.brand)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    // For the scope of this redesign, "Submit for Approval" completes the workflow.
                    // It creates dummy records so the backend process succeeds.
                    let records = varianceItems.map { item in
                        InventoryAdjustmentRecord(
                            cycleCountId: session.id,
                            sessionName: session.title,
                            productName: item.name,
                            sku: item.sku,
                            expected: item.expectedQuantity,
                            counted: item.countedQuantity,
                            difference: item.countedQuantity - item.expectedQuantity,
                            adjustmentType: item.countedQuantity > item.expectedQuantity ? "Extra" : "Missing",
                            reason: "Pending Review",
                            notes: nil,
                            timestamp: Date()
                        )
                    }
                    onComplete(records)
                } label: {
                    Text("Submit for Approval")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.theme.brand)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(16)
                .background(Color.theme.background)
            }
        }
    }
}
