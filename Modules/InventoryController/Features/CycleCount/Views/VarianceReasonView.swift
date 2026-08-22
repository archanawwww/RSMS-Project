import SwiftUI

struct VarianceReasonView: View {
    let item: CycleCountItem
    let countedQuantity: Int
    let onSave: (String, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: String = ""
    @State private var notes: String = ""
    
    private let reasons = [
        "Item Not Found",
        "Damaged / Unsellable",
        "Wrong Location",
        "Misplaced",
        "Counting Error",
        "Duplicate Scan",
        "Other"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Select reason for variance (\(countedQuantity - item.expectedQuantity))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                VStack(spacing: 0) {
                    ForEach(Array(reasons.enumerated()), id: \.element) { index, reason in
                        Button {
                            selectedReason = reason
                        } label: {
                            HStack {
                                Text(reason)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.theme.textPrimary)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "circle.circle.fill")
                                        .foregroundColor(Color.theme.brand)
                                        .font(.system(size: 20))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color.theme.border)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        
                        if index < reasons.count - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 16)
                    
                    TextField("Add any additional details...", text: $notes, axis: .vertical)
                        .font(.system(size: 15))
                        .lineLimit(4...6)
                        .padding(16)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Variance Reason")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                onSave(selectedReason, notes)
                dismiss()
            } label: {
                Text("Save Reason")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedReason.isEmpty ? Color.theme.textDisabled : Color.theme.brand)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(selectedReason.isEmpty)
            .padding(16)
            .background(Color.theme.background)
        }
    }
}
