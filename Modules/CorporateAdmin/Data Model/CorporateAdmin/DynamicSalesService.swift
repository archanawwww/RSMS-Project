import Foundation
import Supabase

struct LivePerformanceData {
    var totalRevenue: Double
    var totalOrders: Int
    var totalItemsSold: Int
    var activeTargetAmount: Double?
}

struct SupabaseSaleRow: Codable {
    let id: UUID
    let totalAmount: Double
}

class DynamicSalesService {
    static let shared = DynamicSalesService()
    
    func fetchPerformance(for storeID: UUID) async throws -> LivePerformanceData {
        let client = SupabaseManager.shared.client
        
        // 1. Fetch Sales for the specific store
        let sales: [SupabaseSaleRow] = try await client.database.from("Sale")
            .select("id, totalAmount")
            .eq("storeID", value: storeID.uuidString)
            .execute().value
            
        let totalRevenue = sales.reduce(0) { $0 + $1.totalAmount }
        let totalOrders = sales.count
        
        // 2. Fetch SalesItems to calculate total items sold
        var totalItemsSold = 0
        if !sales.isEmpty {
            let saleIDs = sales.map { $0.id.uuidString }
            let salesItems: [SalesItem] = try await client.database.from("SalesItem")
                .select()
                .in("saleID", values: saleIDs)
                .execute().value
            totalItemsSold = salesItems.reduce(0) { $0 + $1.quantity }
        }
        
        // 3. Fetch Active StoreSalesTarget
        let targets: [StoreSalesTarget] = try await client.database.from("StoreSalesTarget")
            .select()
            .eq("storeID", value: storeID.uuidString)
            .eq("isActive", value: true)
            .execute().value
            
        // Filter in memory just in case the query boolean matching fails
        let activeTarget = targets.first(where: { $0.isActive })
        
        return LivePerformanceData(
            totalRevenue: totalRevenue,
            totalOrders: totalOrders,
            totalItemsSold: totalItemsSold,
            activeTargetAmount: activeTarget?.targetAmount
        )
    }
}
