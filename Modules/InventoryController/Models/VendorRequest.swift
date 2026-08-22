import Foundation

struct VendorRequest: Identifiable, Codable, Hashable {

    let id: String
    let vendorName: String
    let sku: String
    let productName: String
    let quantity: Int
    var status: ShipmentStatus
    let needByDate: Date
    let createdAt: Date
    let sourceRequestId: String?

    enum CodingKeys: String, CodingKey {

        case id
        case vendorName = "vendor_name"
        case sku
        case productName = "product_name"
        case quantity
        case status
        case needByDate = "need_by_date"
        case createdAt = "created_at"
        case sourceRequestId = "source_request_id"

    }

}
