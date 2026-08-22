import Foundation

struct DashboardSummary: Codable, Hashable {

    let id: Int
    let totalStock: Int
    let lowStockItems: Int
    let pendingRequests: Int
    let incomingShipments: Int

    enum CodingKeys: String, CodingKey {

        case id
        case totalStock = "total_stock"
        case lowStockItems = "low_stock_items"
        case pendingRequests = "pending_requests"
        case incomingShipments = "incoming_shipments"

    }

}
