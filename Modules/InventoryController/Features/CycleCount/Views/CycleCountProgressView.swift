import SwiftUI

struct CycleCountProgressView: View {
    let session: CycleCountSession
    @Binding var items: [CycleCountItem]
    
    @Environment(\.dismiss) private var dismiss
    @State private var showReviewSheet = false
    @State private var showCompletionAlert = false
    @State private var adjustmentRecords: [InventoryAdjustmentRecord] = []
    
    private var totalCount: Int { items.count }
    private var countedCount: Int { items.filter { !$0.state.isNotCounted }.count }
    private var remainingCount: Int { items.filter { $0.state.isNotCounted }.count }
    private var varianceCount: Int { items.filter { $0.state.isVariance }.count }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // ── Progress Card ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(session.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                        Spacer()
                        statusChip("In Progress")
                    }
                    
                    Text("High Value Storage")
                        .font(.system(size: 14))
                        .foregroundColor(Color.theme.textSecondary)
                    
                    Divider().background(Color.theme.border)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Items Counted")
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.textSecondary)
                            Spacer()
                            Text("\(countedCount) of \(totalCount)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.theme.border)
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.theme.brand)
                                    .frame(width: geo.size.width * (totalCount > 0 ? Double(countedCount)/Double(totalCount) : 0), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    
                    VStack(spacing: 12) {
                        statRow(label: "No Variance", value: countedCount - varianceCount, color: Color.theme.success)
                        statRow(label: "With Variance", value: varianceCount, color: Color.theme.brand)
                        statRow(label: "Not Counted", value: remainingCount, color: Color.theme.textDisabled)
                    }
                    .padding(.top, 8)
                }
                .padding(16)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.theme.border, lineWidth: 1))
                .padding(.horizontal, 16)
                
                // ── Recent Items ───────────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Items")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 0) {
                        ForEach(items.filter { !$0.state.isNotCounted }.prefix(5)) { item in
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
                                    Text(item.state.isVariance ? "\(item.countedQuantity - item.expectedQuantity)" : "Match")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(item.state.isVariance ? Color.theme.brand : Color.theme.success)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider().padding(.leading, 68)
                        }
                    }
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.theme.border, lineWidth: 1))
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 24)
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Count Progress")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                if varianceCount > 0 {
                    showReviewSheet = true
                } else {
                    showCompletionAlert = true
                }
            } label: {
                Text("Finish Count")
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
        .sheet(isPresented: $showReviewSheet) {
            ReviewInventoryDifferencesSheet(
                session: session,
                varianceItems: items.filter { $0.state.isVariance }
            ) { records in
                adjustmentRecords = records
                finalizeCompletion()
            }
        }
        .alert("Complete Cycle Count?", isPresented: $showCompletionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Complete") {
                finalizeCompletion()
            }
        } message: {
            Text("All items have been counted with no variances.")
        }
    }
    
    private func statRow(label: String, value: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textSecondary)
            Spacer()
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.theme.textPrimary)
            Circle().fill(color).frame(width: 8, height: 8)
        }
    }
    
    private func statusChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.theme.brand)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.theme.brand.opacity(0.1))
            .overlay(Capsule().stroke(Color.theme.brand.opacity(0.2), lineWidth: 1))
            .clipShape(Capsule())
    }
    
    private func finalizeCompletion() {
        Task {
            try? await CycleCountStore.shared.completeCycleCount(
                session: session,
                items: items,
                adjustmentRecords: adjustmentRecords
            )
            dismiss()
        }
    }
}


