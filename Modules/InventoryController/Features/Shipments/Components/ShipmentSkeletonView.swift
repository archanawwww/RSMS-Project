import SwiftUI

struct ShipmentSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Section
            HStack(alignment: .center, spacing: 12) {
                // Circular Icon
                Circle()
                    .fill(Color(hex: "#F3F2F0"))
                    .frame(width: 40, height: 40)
                
                // ID and Vendor
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#F3F2F0"))
                        .frame(width: 120, height: 16)
                        
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#F3F2F0"))
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
                
                // Status Pill
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#F3F2F0"))
                    .frame(width: 80, height: 24)
            }
            
            Divider()
                .background(Color(hex: "#ECE6DF"))
            
            // Bottom Section
            HStack(spacing: 0) {
                // ETA
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: "#F3F2F0"))
                        .frame(width: 16, height: 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F3F2F0"))
                            .frame(width: 40, height: 10)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F3F2F0"))
                            .frame(width: 100, height: 12)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(height: 30)
                    .background(Color(hex: "#ECE6DF"))
                    .padding(.horizontal, 16)
                
                // ASN
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: "#F3F2F0"))
                        .frame(width: 16, height: 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F3F2F0"))
                            .frame(width: 40, height: 10)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F3F2F0"))
                            .frame(width: 80, height: 12)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#ECE6DF"), lineWidth: 1)
        )
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}
