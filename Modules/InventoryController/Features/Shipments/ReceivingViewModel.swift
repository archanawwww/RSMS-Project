import SwiftUI
import Combine

enum ScanFeedbackState {
    case none
    case success(matchedItem: ASNItem, expected: Int, received: Int)
    case duplicate(item: ASNItem)
    case wrongItem(scannedSku: String, expectedSku: String?)
}

@MainActor
class ReceivingViewModel: ObservableObject {
    private let asnRepo = ASNRepository()
    @Published var session: ReceivingSession
    @Published var feedbackState: ScanFeedbackState = .none
    
    // For navigating within the flow
    @Published var isFinished = false
    
    init(asn: ASN) {
        self.session = ReceivingSession(asn: asn)
    }
    
    func simulateScan(sku: String, serialNumber: String) {
        // Find if item exists in ASN
        guard let itemIndex = session.asn.items.firstIndex(where: { $0.sku == sku }) else {
            // Wrong item
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            feedbackState = .wrongItem(scannedSku: sku, expectedSku: session.asn.items.first?.sku)
            return
        }
        
        let item = session.asn.items[itemIndex]
        
        // Check for duplicate serial
        if session.scannedItems.contains(where: { $0.serialNumber == serialNumber }) {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            feedbackState = .duplicate(item: item)
            return
        }
        
        // Valid scan
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        session.scannedItems.append(ScannedItem(sku: sku, serialNumber: serialNumber))
        session.asn.items[itemIndex].receivedQuantity += 1
        session.asn.totalReceived += 1
        
        // Show success
        feedbackState = .success(
            matchedItem: session.asn.items[itemIndex],
            expected: item.expectedQuantity,
            received: session.asn.items[itemIndex].receivedQuantity
        )
    }
    
    func processScannedCode(_ code: String) {
        simulateScan(sku: code, serialNumber: UUID().uuidString)
    }
    
    func clearFeedback() {
        feedbackState = .none
    }
    
//    func finishReceiving() async {
//
//        do {
//
//            try await asnRepo.updateASN(asn: session.asn)
//
//            try await asnRepo.updateASNItems(items: session.asn.items)
//            
//            try await asnRepo.updateInventoryStock(items: session.asn.items)
//
//            isFinished = true
//
//        } catch {
//
//            print(error)
//        }
//    }
    
    func finishReceiving() async {

        do {

            print("STEP 1")

            try await asnRepo.updateASN(asn: session.asn)

            print("STEP 2")

            try await asnRepo.updateASNItems(items: session.asn.items)

            print("STEP 3")

            try await asnRepo.updateInventoryStock(items: session.asn.items)

            print("STEP 4")

            isFinished = true

        } catch {

            print("ERROR:", error)
        }
    }
    
    var hasVariances: Bool {
        session.asn.items.contains { $0.expectedQuantity != $0.receivedQuantity }
    }
    
    var requiresCycleCountPrompt: Bool {
        // Simulating condition: Replenished a low-stock SKU
        // In a real app, this comes from backend validation
        return true
    }
}
