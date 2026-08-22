import Foundation

struct SerializedItem: Identifiable, Codable, Hashable {
    let id: UUID
    let skuId: UUID
    let shipmentId: UUID
    let asnLineId: UUID?
    let warehouseId: String?
    let storeId: String?
    let serialNumber: String
    let certificateId: UUID?
    var status: String // "Received", "Pending Authentication", "Verified"
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case skuId = "sku_id"
        case shipmentId = "shipment_id"
        case asnLineId = "asn_line_id"
        case warehouseId = "warehouse_id"
        case storeId = "store_id"
        case serialNumber = "serial_number"
        case certificateId = "certificate_id"
        case status
        case createdAt = "created_at"
    }
}
