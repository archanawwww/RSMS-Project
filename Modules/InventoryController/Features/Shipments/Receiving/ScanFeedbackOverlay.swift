import SwiftUI

enum ScanFeedbackType {
    case success
    case duplicate
    case error
    
    var color: Color {
        switch self {
        case .success: return Color.green
        case .duplicate: return Color(hex: "#B9823A") // Warning Orange/Gold
        case .error: return Color.red
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark"
        case .duplicate: return "exclamationmark"
        case .error: return "exclamationmark"
        }
    }
}

struct ScanFeedbackOverlay: View {
    let type: ScanFeedbackType
    let title: String
    var message: String? = nil
    
    // Payload for Success / Duplicate
    var item: ASNItem? = nil
    var expected: Int? = nil
    var received: Int? = nil
    
    // Payload for Error
    var scannedSku: String? = nil
    var expectedSku: String? = nil
    
    var onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Large Status Icon
                ZStack {
                    Circle()
                        .stroke(type.color, lineWidth: 4)
                        .frame(width: 80, height: 80)
                    Image(systemName: type.icon)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(type.color)
                }
                
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(type == .duplicate ? Color.theme.textPrimary : type.color)
                
                // Success / Duplicate Card
                if let i = item {
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
                                Text(i.productName)
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .foregroundColor(Color.theme.textPrimary)
                                Text("SKU: \(i.sku)")
                                    .font(.system(size: 13, weight: .regular, design: .default))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            Spacer()
                        }
                        
                        if let exp = expected, let rec = received {
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Expected Qty")
                                        .font(.system(size: 13, weight: .regular, design: .default))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                    Text("\(exp)")
                                        .font(.system(size: 24, weight: .bold, design: .default))
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Received")
                                        .font(.system(size: 13, weight: .regular, design: .default))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                    Text("\(rec) / \(exp)")
                                        .font(.system(size: 24, weight: .bold, design: .default))
                                        .foregroundColor(type.color)
                                }
                            }
                        }
                        
                        if let msg = message {
                            Divider()
                            Text(msg)
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
                
                // Error Card
                if type == .error {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scanned Item")
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text("SKU: \(scannedSku ?? "Unknown")")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Expected Item")
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text("SKU: \(expectedSku ?? "Unknown")")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Action Buttons
                if type == .duplicate {
                    Button(action: onDismiss) {
                        Text("Scan next item")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                } else if type == .error {
                    VStack(spacing: 12) {
                        Button(action: onDismiss) {
                            Text("Scan Again")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        
                        Button(action: {
                            onDismiss()
                        }) {
                            Text("Report Exception")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundColor(Color.theme.textPrimary)
                                .background(Color.clear)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(UIColor.separator), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .padding(.top, 60)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            let generator = UINotificationFeedbackGenerator()
            switch type {
            case .success: generator.notificationOccurred(.success)
            case .duplicate: generator.notificationOccurred(.warning)
            case .error: generator.notificationOccurred(.error)
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Auto dismiss only on success
            if type == .success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        scale = 0.9
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDismiss()
                    }
                }
            }
        }
    }
}
