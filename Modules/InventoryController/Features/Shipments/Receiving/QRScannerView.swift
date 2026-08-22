import SwiftUI

struct QRScannerView: View {
    let asn: ASN
    @StateObject private var viewModel: ReceivingViewModel
    @Environment(\.dismiss) private var dismiss
    
    // For simulator override
    @State private var showingSimulatorMenu = false
    
    // Manual Entry
    @State private var showingManualEntry = false
    @State private var manualBarcode = ""
    
    init(asn: ASN) {
        self.asn = asn
        self._viewModel = StateObject(wrappedValue: ReceivingViewModel(asn: asn))
    }
    
    var body: some View {
        ZStack {
            // Camera Background
            #if targetEnvironment(simulator)
            Color.black.ignoresSafeArea()
            #else
            DataScannerView { code in
                viewModel.processScannedCode(code)
            }
            .ignoresSafeArea()
            #endif
            
            VStack {
                Text("Align QR code within the frame")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Spacer()
                
                // Scanner Frame Overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 3, dash: [40, 20]))
                        .frame(width: 250, height: 250)
                    
                    // Center Reticle
                    Rectangle()
                        .fill(Color(hex: "#B9823A").opacity(0.8))
                        .frame(width: 250, height: 2)
                        .shadow(color: Color(hex: "#B9823A"), radius: 10, x: 0, y: 0)
                }
                .onTapGesture {
                    #if targetEnvironment(simulator)
                    showingSimulatorMenu = true
                    #endif
                }
                
                Spacer()
                
                // Flashlight button
                Button(action: {}) {
                    Image(systemName: "flashlight.off.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(.bottom, 40)
                
                // Bottom Bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scanned")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.session.scannedItems.count) / \(viewModel.session.asn.totalExpected) Items")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {

                        print("========== FINISH ==========")
                        print("Total Received =", viewModel.session.asn.totalReceived)

                        for item in viewModel.session.asn.items {
                            print("\(item.productName) -> \(item.receivedQuantity)")
                        }

                        Task {
                            await viewModel.finishReceiving()
                        }

                    }) {
                        Text("Finish")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(Color(hex: "#B9823A"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
                .padding(24)
                .background(Color(UIColor.systemBackground).opacity(0.1))
                .background(BlurView(style: .systemThinMaterialDark))
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
            
            // Overlays for Feedback
            if case .success(let matchedItem, let expected, let received) = viewModel.feedbackState {
                ScanFeedbackOverlay(
                    type: .success,
                    title: "Item Matched",
                    item: matchedItem,
                    expected: expected,
                    received: received,
                    onDismiss: { viewModel.clearFeedback() }
                )
            } else if case .duplicate(let item) = viewModel.feedbackState {
                ScanFeedbackOverlay(
                    type: .duplicate,
                    title: "Already Scanned",
                    message: "This carton has already been scanned during this receiving session.",
                    item: item,
                    onDismiss: { viewModel.clearFeedback() }
                )
            } else if case .wrongItem(let scannedSku, let expectedSku) = viewModel.feedbackState {
                ScanFeedbackOverlay(
                    type: .error,
                    title: "ASN Mismatch",
                    scannedSku: scannedSku,
                    expectedSku: expectedSku,
                    onDismiss: { viewModel.clearFeedback() }
                )
            }
        }
        .navigationTitle("Scan Item")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Color(UIColor.label))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Manual Entry") {
                    showingManualEntry = true
                }
                .font(.system(size: 15, weight: .semibold))            }
        }
        .alert("Manual Entry", isPresented: $showingManualEntry) {
            TextField("Enter Barcode or SKU", text: $manualBarcode)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
            
            Button("Cancel", role: .cancel) {
                manualBarcode = ""
            }
            
            Button("Submit") {
                if !manualBarcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    viewModel.processScannedCode(manualBarcode.trimmingCharacters(in: .whitespacesAndNewlines))
                    manualBarcode = ""
                }
            }
        } message: {
            Text("Enter the item's barcode or SKU if scanning is unsuccessful.")
        }
        .actionSheet(isPresented: $showingSimulatorMenu) {
            ActionSheet(title: Text("Simulate Scan"), message: Text("Choose a scenario to test"), buttons: [
                .default(Text("Scan Valid Item (Rolex Daytona)")) {
                    viewModel.simulateScan(sku: "RLX-DAY-001", serialNumber: UUID().uuidString)
                },
                .default(Text("Scan Duplicate Item")) {
                    // Seed one if empty, then scan it again
                    let serial = UUID().uuidString
                    viewModel.simulateScan(sku: "RLX-DAY-001", serialNumber: serial) // 1st
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewModel.simulateScan(sku: "RLX-DAY-001", serialNumber: serial) // 2nd
                    }
                },
                .destructive(Text("Scan Wrong Item")) {
                    viewModel.simulateScan(sku: "UNKNOWN-SKU-999", serialNumber: UUID().uuidString)
                },
                .cancel()
            ])
        }
        .navigationDestination(isPresented: $viewModel.isFinished) {
            QuantityVarianceView(session: viewModel.session)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PopToShipmentDetails"))) { _ in
            dismiss()
        }
    }
}

// Helper for native blur
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    NavigationStack {
        QRScannerView(asn: ASN(
            id: UUID(),
            shipmentId: "SHP-123",
            vendorName: "Acme Corp",
            expectedDate: Date(),
            status: "Pending",
            totalExpected: 0,
            totalReceived: 0,
            createdAt: Date(),
            items: []
        ))
    }
}

