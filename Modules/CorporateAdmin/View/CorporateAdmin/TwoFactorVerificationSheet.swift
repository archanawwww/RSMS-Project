import SwiftUI

struct TwoFactorVerificationSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String
    var onSuccess: () -> Void

    @State private var otpCode = ""
    @State private var isFaceIDScanning = false
    @State private var faceIDSuccess = false
    @State private var errorMessage: String? = nil
    
    // Glass styling helper variables
    @State private var rotationAngle: Double = 0.0
    @State private var scanScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Dark elegant glass sheet background
            MatteTheme.Colors.dashboardBackground
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Header handles
                Capsule()
                    .fill(MatteTheme.Colors.border)
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                VStack(spacing: 8) {
                    Text("Security Gateway")
                        .font(.caption.weight(.bold))
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                        .kerning(1.5)
                    
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // FACE ID Scanning Section (iOS 26 Style)
                ZStack {
                    Color.clear
                        .frame(width: 140, height: 140)
                        .glassEffect(.regular, in: .rect(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(faceIDSuccess ? MatteTheme.Colors.success : MatteTheme.Colors.primaryGold.opacity(0.4), lineWidth: 1.5)
                        )
                    
                    if faceIDSuccess {
                        // Success state icon
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 64))
                            .foregroundColor(MatteTheme.Colors.success)
                            .transition(.scale.combined(with: .opacity))
                    } else if isFaceIDScanning {
                        // Face ID Scanning line animation
                        Image(systemName: "faceid")
                            .font(.system(size: 54))
                            .foregroundColor(MatteTheme.Colors.primaryGold)
                            .scaleEffect(scanScale)
                            .overlay(
                                // A moving scanner bar
                                GeometryReader { proxy in
                                    Capsule()
                                        .fill(MatteTheme.Colors.primaryGold)
                                        .frame(height: 3)
                                        .offset(y: rotationAngle)
                                }
                            )
                    } else {
                        // Prompt Face ID state
                        Button(action: startFaceIDScan) {
                            VStack(spacing: 8) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 48))
                                    .foregroundColor(MatteTheme.Colors.espresso)
                                Text("Verify Face ID")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(MatteTheme.Colors.espresso)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 140)
                
                // OTP Fallback
                VStack(spacing: 12) {
                    Text("— OR ENTER OTP CODE —")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                        .kerning(1.2)
                    
                    TextField("Enter 6-digit passcode (123456)", text: $otpCode)
                        .keyboardType(.numberPad)
                        .matteFieldStyle()
                        .padding(.horizontal, 24)
                        .onChange(of: otpCode) { oldValue, newValue in
                            if otpCode.count == 6 {
                                verifyOTP()
                            }
                        }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption2)
                            .foregroundColor(MatteTheme.Colors.error)
                    }
                }
                
                // Verification Button
                Button(action: {
                    if otpCode.isEmpty {
                        startFaceIDScan()
                    } else {
                        verifyOTP()
                    }
                }) {
                    Text(otpCode.isEmpty ? "Scan Face ID" : "Verify OTP")
                        .font(.headline)
                        .foregroundColor(MatteTheme.Colors.ivoryMatte)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(faceIDSuccess ? MatteTheme.Colors.success : MatteTheme.Colors.espresso)
                        .cornerRadius(16)
                        .shadow(color: MatteTheme.Colors.espresso.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .padding(.horizontal, 24)
                
                Button("Cancel") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
                .padding(.bottom, 16)
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func startFaceIDScan() {
        errorMessage = nil
        isFaceIDScanning = true
        rotationAngle = 0
        
        // scanning line animation loop
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            rotationAngle = 100
            scanScale = 1.0
        }
        
        // Mock Face ID Success after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isFaceIDScanning = false
            withAnimation(.spring()) {
                faceIDSuccess = true
            }
            
            // Haptic Feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onSuccess()
                dismiss()
            }
        }
    }
    
    private func verifyOTP() {
        if otpCode == "123456" {
            errorMessage = nil
            withAnimation {
                faceIDSuccess = true
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onSuccess()
                dismiss()
            }
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            errorMessage = "Invalid security code. Please use 123456."
            otpCode = ""
        }
    }
}
