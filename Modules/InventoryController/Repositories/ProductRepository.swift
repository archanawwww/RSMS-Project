import Foundation
import Supabase

private struct InventoryProductResponse: Decodable {

    let currentStock: Int
    let reorderThreshold: Int
    let product: ProductData

    enum CodingKeys: String, CodingKey {
        case currentStock = "current_stock"
        case reorderThreshold = "reorder_threshold"
        case product = "Product"
    }
}

private struct ProductData: Decodable {

    let id: UUID
    let sku: String
    let name: String
    let brand: String
    let category: String
    let barcode: String?
    let basePrice: Double
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sku
        case name
        case brand
        case category
        case barcode
        case basePrice = "basePrice"
        case imageUrl = "image_url"
    }
}

class ProductRepository {

    func fetchProducts() async throws -> [Product] {

        let products: [Product] = try await SupabaseService.shared.client
            .from("Product")
            .select()
            .execute()
            .value

        return products
    }
    
    func fetchInventoryProducts() async throws -> [Product] {

        let rows: [InventoryProductResponse] = try await SupabaseService.shared.client
            .from("inventory_stock")
            .select("""
                current_stock,
                reorder_threshold,
                Product(
                    id,
                    sku,
                    name,
                    brand,
                    category,
                    barcode,
                    basePrice,
                    image_url
                )
            """)
            .execute()
            .value

        return rows.map {
            Product(
                id: $0.product.id,
                sku: $0.product.sku,
                name: $0.product.name,
                brand: $0.product.brand,
                category: $0.product.category,
                barcode: $0.product.barcode,
                basePrice: $0.product.basePrice,
                imageUrl: $0.product.imageUrl,
                currentStock: $0.currentStock,
                reorderThreshold: $0.reorderThreshold
            )
        }
    }
}
