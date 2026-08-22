import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    let sku: String
    let name: String
    let brand: String
    let category: String
    let barcode: String?
    let basePrice: Double
    let imageUrl: String?

    let currentStock: Int?
    let reorderThreshold: Int?

    enum CodingKeys: String, CodingKey {

        case id

        case sku

        case name

        case brand

        case category

        case barcode

        case basePrice = "basePrice"

        case imageUrl = "image_url"
        
        case currentStock = "current_stock"
        case reorderThreshold = "reorder_threshold"

    }
    
    
}

extension Product {
    var isLowStock: Bool {
        guard let currentStock, let reorderThreshold else { return false }
        return currentStock <= reorderThreshold
    }
}
