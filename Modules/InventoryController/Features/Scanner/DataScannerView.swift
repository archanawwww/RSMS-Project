import SwiftUI
import VisionKit
import Vision

struct DataScannerView: UIViewControllerRepresentable {
    let onScan: (String) -> Void
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        var lastScanTime: Date?
        var lastScannedValue: String?
        
        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                if case let .barcode(barcode) = item {
                    if let payload = barcode.payloadStringValue {
                        let now = Date()
                        // Prevent duplicate reads of same code within 2 seconds
                        if let lastTime = lastScanTime, let lastValue = lastScannedValue, lastValue == payload, now.timeIntervalSince(lastTime) < 2.0 {
                            continue
                        }
                        
                        lastScanTime = now
                        lastScannedValue = payload
                        onScan(payload)
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr, .code128, .ean13, .ean8, .upce])],
            qualityLevel: .fast,
            recognizesMultipleItems: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            try? uiViewController.startScanning()
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
}

#Preview {
    Text("DataScannerView requires physical camera hardware to preview.")
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
}
