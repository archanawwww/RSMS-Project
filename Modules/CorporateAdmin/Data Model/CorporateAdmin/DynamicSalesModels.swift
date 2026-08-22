import Foundation

// MARK: - SalesItem
struct SalesItem: Identifiable, Codable {
    let id: UUID
    let saleID: UUID
    let productID: UUID
    let quantity: Int
    let unitPrice: Double
    let subTotal: Double
    let time: String?
}

// MARK: - StoreSalesTarget
struct StoreSalesTarget: Identifiable, Codable {
    let id: UUID
    let storeID: UUID
    let targetAmount: Double
    let currency: String
    let period: String
    let startDate: String
    let endDate: String
    let isActive: Bool
}
