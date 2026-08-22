import SwiftUI

struct SignatureView: View {
    let onSign: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var signatureLines: [[CGPoint]] = []
    
    var body: some View {
        VStack(spacing: 24) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Manager Signature")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text("Please sign below to approve the cycle count adjustments.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            
            // Signature Pad
            ZStack {
                Color.theme.surface
                
                if signatureLines.isEmpty {
                    Text("Sign Here")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.theme.border)
                }
                
                Path { path in
                    for line in signatureLines {
                        guard let first = line.first else { continue }
                        path.move(to: first)
                        for point in line.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.theme.textPrimary, lineWidth: 3)
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
            .padding(.horizontal, 16)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let position = value.location
                        if value.translation == .zero {
                            signatureLines.append([position])
                        } else {
                            guard let lastIdx = signatureLines.indices.last else { return }
                            signatureLines[lastIdx].append(position)
                        }
                    }
            )
            
            Button("Clear Signature") {
                signatureLines.removeAll()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.theme.brand)
            
            Spacer()
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Approval")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                onSign()
            } label: {
                Text("Confirm Approval")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(signatureLines.isEmpty ? Color.theme.textDisabled : Color.theme.brand)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(signatureLines.isEmpty)
            .padding(16)
            .background(Color.theme.background)
        }
    }
}
