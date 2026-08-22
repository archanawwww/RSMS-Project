import SwiftUI
import LocalAuthentication

struct ManagerReviewView: View {
    let session: CycleCountSession
    let varianceItems: [CycleCountItem]
    let onApprove: () -> Void
    let onReject: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingSignature = false
    @State private var authError: String? = nil
    
    private var totalVarianceValue: Double {
        varianceItems.reduce(0.0) { sum, item in
            let diff = item.countedQuantity - item.expectedQuantity
            return sum + (Double(diff) * (item.basePrice ?? 0.0))
        }
    }
    
    var body: some View {
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
                        statRow("Items Counted", "\(session.total)")
                        statRowWithDot("No Variance", "\(session.total - varianceItems.count)", Color.theme.success)
                        statRowWithDot("With Variance", "\(varianceItems.count)", Color.theme.brand)
                        
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
                
                // ── Variances ──────────────────────────────────────────────
                if !varianceItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Items with Variance")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(varianceItems.enumerated()), id: \.element.id) { index, item in
                                let diff = item.countedQuantity - item.expectedQuantity
                                
                                VStack(spacing: 12) {
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
                                            Text("Counted: \(item.countedQuantity)")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.theme.textSecondary)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Reason: Missing") // Mocked reason for redesign purposes
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.theme.textSecondary)
                                        Spacer()
                                    }
                                    .padding(.leading, 52)
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
                
                if let error = authError {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }
                
            }
            .padding(.vertical, 24)
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Manager Review")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button {
                    authenticate()
                } label: {
                    Text("Approve Adjustment")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.theme.brand)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                Button {
                    onReject()
                    dismiss()
                } label: {
                    Text("Reject Count")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                }
            }
            .padding(16)
            .background(Color.theme.background)
        }
        .navigationDestination(isPresented: $showingSignature) {
            SignatureView {
                onApprove()
                dismiss()
            }
        }
    }
    
    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.theme.textPrimary)
        }
    }
    
    private func statRowWithDot(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textSecondary)
            Spacer()
            HStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.textPrimary)
                Circle().fill(color).frame(width: 8, height: 8)
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to approve adjustment") { success, error in
                DispatchQueue.main.async {
                    if success {
                        showingSignature = true
                    } else {
                        self.authError = error?.localizedDescription ?? "Authentication failed."
                        // Fallback to signature if biometric fails or denied for now
                        showingSignature = true
                    }
                }
            }
        } else {
            // No biometrics available, proceed to signature
            showingSignature = true
        }
    }
}
