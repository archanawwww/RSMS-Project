import Foundation

struct ReceivingSession: Identifiable, Hashable {
    let id: UUID
    var asn: ASN
    var scannedItems: [ScannedItem]
    var discrepancies: [Discrepancy]
    
    init(asn: ASN, scannedItems: [ScannedItem] = [], discrepancies: [Discrepancy] = []) {
        self.id = UUID()
        self.asn = asn
        self.scannedItems = scannedItems
        self.discrepancies = discrepancies
    }
}

struct ScannedItem: Identifiable, Hashable {
    let id: UUID
    let sku: String
    let serialNumber: String
    let timestamp: Date
    
    init(sku: String, serialNumber: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.sku = sku
        self.serialNumber = serialNumber
        self.timestamp = timestamp
    }
}

struct Discrepancy: Identifiable, Hashable {
    let id: UUID
    let asnItemId: String
    let reason: DiscrepancyReason
    let notes: String?
    
    init(asnItemId: String, reason: DiscrepancyReason, notes: String? = nil) {
        self.id = UUID()
        self.asnItemId = asnItemId
        self.reason = reason
        self.notes = notes
    }
}

enum DiscrepancyReason: String, CaseIterable, Identifiable, Hashable, Codable {
    case overShipment = "Over Shipment"
    case shortShipment = "Short Shipment"
    case damaged = "Damaged"
    case wrongItem = "Wrong Item"
    case missingItem = "Missing Item"
    case other = "Other"
    
    var id: String { rawValue }
}
