import Foundation
import Supabase

private struct StoreRequestToInventoryRow: Decodable {
    let id: UUID
    let requesttype: String
    let storeid: UUID
    let store: StoreRequestStoreLookup?
    let productid: UUID
    let quantityrequested: Int
    let priority: String
    let status: String
    let createdat: String?

    enum CodingKeys: String, CodingKey {
        case id
        case requesttype
        case storeid
        case store
        case productid
        case quantityrequested
        case priority
        case status
        case createdat
    }
}

private struct StoreRequestProductLookup: Decodable {
    let id: UUID
    let sku: String
    let name: String
}

private struct StoreRequestStoreLookup: Decodable {
    let name: String
}

private struct StoreInventoryRow: Decodable {
    let id: UUID
    let currentquantity: Int
}

private struct StoreInventoryUpdate: Encodable {
    let currentquantity: Int
    let updatedat: String
}

private struct StoreInventoryInsert: Encodable {
    let id: UUID
    let storeid: UUID
    let productid: UUID
    let currentquantity: Int
    let thresholdquantity: Int
    let updatedat: String
}

private struct WarehouseInventoryStockRow: Decodable {
    let id: UUID
    let currentStock: Int

    enum CodingKeys: String, CodingKey {
        case id
        case currentStock = "current_stock"
    }
}

private struct WarehouseInventoryStockUpdate: Encodable {
    let currentStock: Int

    enum CodingKeys: String, CodingKey {
        case currentStock = "current_stock"
    }
}

private struct StoreRequestStatusUpdate: Encodable {
    let status: String
}

private struct StoreRequestStatusRow: Decodable {
    let id: UUID
    let status: String
}

class StoreRequestRepository {

    func fetchStoreRequests() async throws -> [StoreRequest] {

        let rows: [StoreRequestToInventoryRow] = try await SupabaseService.shared.client
            .from("StoreRequestToInventory")
            .select("""
                *,
                store:Store(name)
            """)
            .execute()
            .value

        let productsById = await fetchProductsById()

        return rows
            .sorted { parseDate($0.createdat) > parseDate($1.createdat) }
            .map { row in
                let product = productsById[row.productid]
                return StoreRequest(
                    id: row.id.uuidString,
                    requestType: RequestType(rawValue: row.requesttype) ?? .refill,
                    storeName: row.store?.name ?? "Store \(row.storeid.uuidString.prefix(8))",
                    sku: product?.sku ?? row.productid.uuidString,
                    productName: product?.name ?? "Product \(row.productid.uuidString.prefix(8))",
                    quantityRequested: row.quantityrequested,
                    priority: Priority(rawValue: row.priority.lowercased()) ?? .normal,
                    managerRemark: nil,
                    status: RequestStatus(rawValue: row.status.lowercased()) ?? .pending,
                    createdAt: parseDate(row.createdat)
                )
            }
    }

    func approveRequest(id: String) async throws {
        guard let requestId = UUID(uuidString: id) else { return }

        guard let request = try await fetchStoreRequestRow(id: requestId) else { return }

        try await validateWarehouseInventoryCanFulfill(request)
        try await applyApprovedQuantityToStoreInventory(for: request)
        try await deductApprovedQuantityFromWarehouseInventory(for: request)
        try await updateRequestStatus(id: requestId, status: .fulfilled)
    }

    func rejectRequest(id: String) async throws {
        guard let requestId = UUID(uuidString: id) else { return }
        try await updateRequestStatus(id: requestId, status: .rejected)
    }

    private func fetchProductsById() async -> [UUID: StoreRequestProductLookup] {
        do {
            let products: [StoreRequestProductLookup] = try await SupabaseService.shared.client
                .from("Product")
                .select("id,sku,name")
                .execute()
                .value

            return Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
        } catch {
            print("Error loading products for store requests: \(error)")
            return [:]
        }
    }

    private func fetchStoreRequestRow(id: UUID) async throws -> StoreRequestToInventoryRow? {
        let rows: [StoreRequestToInventoryRow] = try await SupabaseService.shared.client
            .from("StoreRequestToInventory")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
            .value

        return rows.first
    }

    private func parseDate(_ value: String?) -> Date {
        guard let value, !value.isEmpty else { return Date.distantPast }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        return Date.distantPast
    }

    private func updateRequestStatus(id: UUID, status: RequestStatus) async throws {
        let update = StoreRequestStatusUpdate(status: status.rawValue)

        let updatedRows: [StoreRequestStatusRow] = try await SupabaseService.shared.client
            .from("StoreRequestToInventory")
            .update(update)
            .eq("id", value: id.uuidString)
            .select("id,status")
            .execute()
            .value

        guard updatedRows.contains(where: { $0.id == id && $0.status.lowercased() == status.rawValue }) else {
            throw StoreRequestRepositoryError.statusUpdateFailed
        }
    }

    private func applyApprovedQuantityToStoreInventory(for request: StoreRequestToInventoryRow) async throws {
        let existingRows: [StoreInventoryRow] = try await SupabaseService.shared.client
            .from("StoreInventory")
            .select("id,currentquantity")
            .eq("storeid", value: request.storeid.uuidString)
            .eq("productid", value: request.productid.uuidString)
            .execute()
            .value

        let updatedAt = ISO8601DateFormatter().string(from: Date())

        if let existingRow = existingRows.first {
            let update = StoreInventoryUpdate(
                currentquantity: existingRow.currentquantity + request.quantityrequested,
                updatedat: updatedAt
            )

            try await SupabaseService.shared.client
                .from("StoreInventory")
                .update(update)
                .eq("id", value: existingRow.id.uuidString)
                .execute()
        } else {
            let insert = StoreInventoryInsert(
                id: UUID(),
                storeid: request.storeid,
                productid: request.productid,
                currentquantity: request.quantityrequested,
                thresholdquantity: 5,
                updatedat: updatedAt
            )

            try await SupabaseService.shared.client
                .from("StoreInventory")
                .insert(insert)
                .execute()
        }
    }

    private func validateWarehouseInventoryCanFulfill(_ request: StoreRequestToInventoryRow) async throws {
        let stock = try await fetchWarehouseInventoryStock(productId: request.productid)

        guard stock.currentStock >= request.quantityrequested else {
            throw StoreRequestRepositoryError.insufficientWarehouseStock(
                available: stock.currentStock,
                requested: request.quantityrequested
            )
        }
    }

    private func deductApprovedQuantityFromWarehouseInventory(for request: StoreRequestToInventoryRow) async throws {
        let stock = try await fetchWarehouseInventoryStock(productId: request.productid)
        let update = WarehouseInventoryStockUpdate(
            currentStock: stock.currentStock - request.quantityrequested
        )

        try await SupabaseService.shared.client
            .from("inventory_stock")
            .update(update)
            .eq("id", value: stock.id.uuidString)
            .execute()
    }

    private func fetchWarehouseInventoryStock(productId: UUID) async throws -> WarehouseInventoryStockRow {
        let rows: [WarehouseInventoryStockRow] = try await SupabaseService.shared.client
            .from("inventory_stock")
            .select("id,current_stock")
            .eq("product_id", value: productId.uuidString)
            .execute()
            .value

        guard let stock = rows.first else {
            throw StoreRequestRepositoryError.missingWarehouseStock
        }

        return stock
    }
}

enum StoreRequestRepositoryError: LocalizedError {
    case statusUpdateFailed
    case missingWarehouseStock
    case insufficientWarehouseStock(available: Int, requested: Int)

    var errorDescription: String? {
        switch self {
        case .statusUpdateFailed:
            return "Supabase did not confirm the request status update."
        case .missingWarehouseStock:
            return "No warehouse inventory record exists for this product."
        case let .insufficientWarehouseStock(available, requested):
            return "Warehouse inventory has only \(available) units, but \(requested) were requested."
        }
    }
}
