import Foundation

struct ASNItem: Identifiable, Codable, Hashable {

    let id: UUID

    let asnId: String

    let productId: UUID?

    let sku: String

    let productName: String

    let productImageURL: String?

    let expectedQuantity: Int

    var receivedQuantity: Int

    enum CodingKeys: String, CodingKey {
        case id
        case asnId = "asn_id"
        case productId = "product_id"
        case sku
        case productName = "product_name"
        case productImageURL = "image_url"
        case expectedQuantity = "expected_quantity"
        case receivedQuantity = "received_quantity"
    }

    var isMatched: Bool {
        receivedQuantity >= expectedQuantity
    }
}
