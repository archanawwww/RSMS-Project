import SwiftUI

struct ProductCountingView: View {
    let item: CycleCountItem
    let onComplete: (CycleCountItemState) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var countedQuantity: Int
    
    init(item: CycleCountItem, onComplete: @escaping (CycleCountItemState) -> Void) {
        self.item = item
        self.onComplete = onComplete
        
        switch item.state {
        case .notCounted:
            _countedQuantity = State(initialValue: 0)
        case .matched(_, let counted):
            _countedQuantity = State(initialValue: counted)
        case .variance(_, let counted):
            _countedQuantity = State(initialValue: counted)
        }
    }
    
    private var expectedQuantity: Int {
        switch item.state {
        case .notCounted(let expected): return expected
        case .matched(let expected, _): return expected
        case .variance(let expected, _): return expected
        }
    }
    
    private var variance: Int {
        countedQuantity - expectedQuantity
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // ── Item Details Card ──────────────────────────────────────
                VStack(spacing: 16) {
                    InventoryProductThumbnail(imageUrl: item.imageUrl, category: item.category, size: 80)
                        .padding(.top, 16)
                    
                    VStack(spacing: 4) {
                        Text(item.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(item.sku)
                            .font(.system(size: 14))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    Divider().background(Color.theme.border)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Location")
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.textSecondary)
                            Text("Tray A-05") // Mocked location
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("System Quantity")
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.textSecondary)
                            Text("\(expectedQuantity)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                .padding(.horizontal, 16)
                
                // ── Counter Card ───────────────────────────────────────────
                VStack(spacing: 24) {
                    Text("Enter Counted Quantity")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.top, 16)
                    
                    HStack(spacing: 24) {
                        Button {
                            if countedQuantity > 0 { countedQuantity -= 1 }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color.theme.brand)
                                .frame(width: 60, height: 60)
                                .background(Color.theme.brand.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Text("\(countedQuantity)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                            .frame(minWidth: 80)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            countedQuantity += 1
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color.theme.brand)
                                .frame(width: 60, height: 60)
                                .background(Color.theme.brand.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    Button("Enter Manually") {
                        // Action to show keypad (mocked here by keeping it simple)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.brand)
                    
                    Divider().background(Color.theme.border)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Variance")
                                .font(.system(size: 14))
                                .foregroundColor(Color.theme.textSecondary)
                            Spacer()
                            Text("\(variance > 0 ? "+" : "")\(variance)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(variance == 0 ? Color.theme.textPrimary : Color.theme.brand)
                        }
                        
                        if variance != 0, let price = item.basePrice {
                            HStack {
                                Text("Variance Value")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textSecondary)
                                Spacer()
                                Text(String(format: "$%.2f", abs(Double(variance) * price)))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.theme.brand)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                .padding(.horizontal, 16)
                
            }
            .padding(.vertical, 24)
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Count Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Skip") {
                    dismiss()
                }
                .foregroundColor(Color.theme.brand)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                saveAndContinue()
            } label: {
                Text("Next Item")
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
        .navigationDestination(isPresented: $navigateToVarianceReason) {
            VarianceReasonView(item: item, countedQuantity: countedQuantity) { reason, notes in
                // In a real app we'd save this reason, but for now we just mark variance
                let newState = CycleCountItemState.variance(expected: expectedQuantity, counted: countedQuantity)
                onComplete(newState)
                dismiss() // This will dismiss VarianceReasonView, but what about ProductCountingView?
                // Using a callback or a dismiss to root might be needed, but since it's navigation, 
                // onComplete will notify Scanner which dismisses this view.
            }
        }
    }
    
    @State private var navigateToVarianceReason = false
    
    // Inside body: add navigation destination
    // Wait, let's just append it to the body.
    
    private func saveAndContinue() {
        if variance == 0 {
            let newState = CycleCountItemState.matched(expected: expectedQuantity, counted: countedQuantity)
            onComplete(newState)
            dismiss()
        } else {
            navigateToVarianceReason = true
        }
    }
}
