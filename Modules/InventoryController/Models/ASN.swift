import Foundation

struct ASN: Identifiable, Codable, Hashable {

    let id: UUID
    let shipmentId: String
    let vendorName: String
    let expectedDate: Date
    var status: String

    var totalExpected: Int
    var totalReceived: Int

    let createdAt: Date

    var items: [ASNItem] = []

    var totalPending: Int {
        max(0, totalExpected - totalReceived)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case shipmentId = "shipment_id"
        case vendorName = "vendor_name"
        case expectedDate = "expected_date"
        case status
        case totalExpected = "total_expected"
        case totalReceived = "total_received"
        case createdAt = "created_at"
    }
}
