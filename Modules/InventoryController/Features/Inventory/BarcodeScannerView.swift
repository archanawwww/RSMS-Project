import SwiftUI
import AVFoundation
import Combine

// MARK: - Scanner ViewModel

final class BarcodeScannerModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    
    @Published var lastScannedSerial:   String? = nil
    @Published var showSuccessFeedback: Bool     = false
    @Published var isTorchOn:           Bool     = false
    @Published var permissionDenied:    Bool     = false

    let session            = AVCaptureSession()
    private var configured = false

    /// Accessed from nonisolated delegate — must be nonisolated(unsafe).
    nonisolated(unsafe) private var lastScanAt: TimeInterval = 0

    /// Called off-main for every de-duplicated scan; dispatches to main internally.
    nonisolated(unsafe) var onNewSerial: ((String) -> Void)?

    // MARK: Lifecycle
    
    func configureAndStart() {
        guard !configured else { startRunning(); return }
        configured = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            _setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted { self?._setupSession() }
                else { DispatchQueue.main.async { self?.permissionDenied = true } }
            }
        default:
            DispatchQueue.main.async { self.permissionDenied = true }
        }
    }
    
    private func _setupSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            
            guard
                let device = AVCaptureDevice.default(for: .video),
                let input  = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else { self.session.commitConfiguration(); return }
            
            self.session.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            guard self.session.canAddOutput(output) else {
                self.session.commitConfiguration(); return
            }
            self.session.addOutput(output)
            // Deliver on a private serial queue — the nonisolated delegate method
            // then hops to MainActor explicitly, satisfying Swift 6 strict concurrency.
            let q = DispatchQueue(label: "com.rsms.scanner.metadata", qos: .userInteractive)
            output.setMetadataObjectsDelegate(self, queue: q)
            output.metadataObjectTypes = [
                .qr, .ean13, .ean8, .code128, .code39,
                .code93, .upce, .pdf417, .aztec, .dataMatrix
            ]
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    func startRunning() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopRunning() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func toggleTorch() {
        guard
            let device = AVCaptureDevice.default(for: .video),
            device.hasTorch
        else { return }
        try? device.lockForConfiguration()
        device.torchMode = device.torchMode == .on ? .off : .on
        isTorchOn = device.torchMode == .on
        device.unlockForConfiguration()
    }

    // nonisolated — AVFoundation calls this on the queue set in setMetadataObjectsDelegate.
    // All UI state mutations are hopped to @MainActor via Task.
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput objects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let obj   = objects.first as? AVMetadataMachineReadableCodeObject,
            let value = obj.stringValue,
            Date().timeIntervalSinceReferenceDate - lastScanAt > 1.5   // debounce
        else { return }

        lastScanAt = Date().timeIntervalSinceReferenceDate

        // Haptic is UIKit — must run on main thread.
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        // Capture callback before the Task so it doesn't cross an isolation boundary.
        let callback = onNewSerial

        Task { @MainActor [weak self] in
            guard let self else { return }
            self.lastScannedSerial  = value
            self.showSuccessFeedback = true
            callback?(value)

            try? await Task.sleep(for: .seconds(1.5))
            self.showSuccessFeedback = false
            self.lastScannedSerial   = nil
        }
    }
}
    
    // MARK: - Camera Preview (UIViewRepresentable)
    
    struct CameraPreviewView: UIViewRepresentable {
        let session: AVCaptureSession
        
        // Use AVCaptureVideoPreviewLayer as the backing layer for zero-copy efficiency
        final class PreviewView: UIView {
            override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
            var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
        }
        
        func makeUIView(context: Context) -> PreviewView {
            let view = PreviewView()
            view.backgroundColor            = .black
            view.previewLayer.session       = session
            view.previewLayer.videoGravity  = .resizeAspectFill
            return view
        }
        
        func updateUIView(_ uiView: PreviewView, context: Context) { }
    }
    
    // MARK: - Barcode Scanner View
    
    struct BarcodeScannerView: View {
        @Binding var scannedSerials: [String]
        let expectedCount: Int
        let onFinish: () -> Void
        
        @StateObject private var vm          = BarcodeScannerModel()
        @State       private var scanLineY:  CGFloat = -80
        
        var body: some View {
            ZStack {
                // ── Live camera feed ───────────────────────────────────────────
                Color.black.ignoresSafeArea()
                CameraPreviewView(session: vm.session).ignoresSafeArea()
                
                // ── UI overlay ─────────────────────────────────────────────────
                VStack(spacing: 0) {
                    
                    // Cancel — top left
                    HStack {
                        Button("Cancel") { onFinish() }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(.black.opacity(0.55))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Instruction
                    Text("Align barcode or QR code within the frame")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.90))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                        .padding(.bottom, 22)
                    
                    // ── Scanning frame ─────────────────────────────────────────
                    ZStack {
                        // Dashed border
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.75),
                                    style: StrokeStyle(lineWidth: 2, dash: [14, 8]))
                        
                        // Animated scan line (warm brown)
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, Color.theme.accent, .clear]),
                            startPoint: .leading, endPoint: .trailing
                        )
                        .frame(height: 2)
                        .offset(y: scanLineY)
                    }
                    .frame(width: 280, height: 200)
                    .clipped()
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            scanLineY = 80
                        }
                    }
                    
                    Spacer()
                    
                    // Torch toggle
                    Button { vm.toggleTorch() } label: {
                        Image(systemName: vm.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 22))
                            .foregroundColor(vm.isTorchOn ? Color.theme.accent : .white.opacity(0.55))
                    }
                    .padding(.bottom, 24)
                    
                    // ── Bottom bar ─────────────────────────────────────────────
                    bottomBar
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                vm.onNewSerial = { serial in
                    guard !scannedSerials.contains(serial) else { return }
                    scannedSerials.append(serial)
                }
                vm.configureAndStart()
            }
            .onDisappear { vm.stopRunning() }
        }
        
        // MARK: Bottom Bar
        
        private var bottomBar: some View {
            HStack(alignment: .center, spacing: 0) {
                
                // Left: live scan status
                VStack(alignment: .leading, spacing: 3) {
                    if vm.showSuccessFeedback, let serial = vm.lastScannedSerial {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.systemGreen))
                            Text(serial)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        Text("Scanned successfully")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.55))
                    } else {
                        Text("Scanned")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(scannedSerials.count) / \(expectedCount) Items")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: vm.showSuccessFeedback)
                
                Spacer()
                
                // Right: Finish
                Button("Finish") { onFinish() }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.theme.accent)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.theme.accent, lineWidth: 1.5)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 34)
            .background(.ultraThinMaterial)
        }
    
    }

#Preview {
    BarcodeScannerView(
        scannedSerials: .constant([]),
        expectedCount: 5,
        onFinish: { }
    )
}

