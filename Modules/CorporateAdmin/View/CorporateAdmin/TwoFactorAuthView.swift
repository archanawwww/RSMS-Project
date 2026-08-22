import SwiftUI

struct TwoFactorAuthView: View {
    @State private var otpCode: String = ""
    @State private var errorMessage: String? = nil
    var onSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundColor(MatteTheme.Colors.primaryGold)
            
            Text("Two-Factor Authentication")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(MatteTheme.Colors.textPrimary)
            
            Text("Please enter the 6-digit code sent to your registered device to access Product Master Records.")
                .font(.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            TextField("Enter 6-digit code", text: $otpCode)
                .keyboardType(.numberPad)
                .textFieldStyle(.plain)
                .padding()
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                .padding(.horizontal, 32)
            
            if let error = errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(MatteTheme.Colors.error)
            }
            
            Button(action: verifyCode) {
                Text("Verify")
                    .font(.headline)
                    .foregroundColor(MatteTheme.Colors.ivoryMatte)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(MatteTheme.Colors.espresso)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding(.top, 64)
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
    }
    
    private func verifyCode() {
        // Mock 2FA verification: Accept any 6 digit code for now, or exactly "123456"
        if otpCode == "123456" {
            errorMessage = nil
            onSuccess()
        } else {
            errorMessage = "Invalid code. Please use 123456 for testing."
        }
    }
}
