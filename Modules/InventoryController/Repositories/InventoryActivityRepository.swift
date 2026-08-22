import Foundation
import Supabase

struct SupabaseSalesItem: Codable {
    let id: String
    let saleID: String
    let productID: String
    let quantity: Int
    let unitPrice: Double
    let subTotal: Double
    let time: String?
}

struct SupabaseASNItemActivity: Codable {
    let id: String
    let asn_id: String
    let product_id: String?
    let sku: String
    let product_name: String
    let expected_quantity: Int
    let received_quantity: Int
    let image_url: String?
}

class InventoryActivityRepository {

    func fetchMovements(for productId: String) async throws -> [InventoryMovement] {
        var movements: [InventoryMovement] = []

        do {
            let serializedItems: [SerializedItem] = try await SupabaseService.shared.client
                .from("serialized_items")
                .select()
                .eq("sku_id", value: productId)
                .execute()
                .value

            for item in serializedItems {
                movements.append(InventoryMovement(
                    delta: +1,
                    description: item.status.isEmpty ? "Received" : item.status,
                    occurredAt: item.createdAt
                ))
            }
        } catch {
            print("[InventoryActivityRepository] Failed to fetch serialized scan activity: \(error)")
        }

        do {
            let salesItems: [SupabaseSalesItem] = try await SupabaseService.shared.client
                .from("SalesItem")
                .select()
                .eq("productID", value: productId)
                .execute()
                .value

            for item in salesItems {
                movements.append(InventoryMovement(
                    delta: -item.quantity,
                    description: "Sold",
                    occurredAt: Self.parseDate(item.time)
                ))
            }
        } catch {
            print("[InventoryActivityRepository] Failed to fetch sales activity: \(error)")
        }

        do {
            let asnItems: [SupabaseASNItemActivity] = try await SupabaseService.shared.client
                .from("asn_items")
                .select()
                .eq("product_id", value: productId)
                .execute()
                .value

            if movements.isEmpty {
                for item in asnItems where item.received_quantity > 0 {
                    movements.append(InventoryMovement(
                        delta: item.received_quantity,
                        description: "Received via ASN",
                        occurredAt: nil
                    ))
                }
            }
        } catch {
            print("[InventoryActivityRepository] Failed to fetch ASN activity: \(error)")
        }

        if movements.isEmpty {
            movements.append(InventoryMovement(
                delta: 0,
                description: "No activity recorded",
                occurredAt: nil
            ))
        }

        return movements.sorted { lhs, rhs in
            switch (lhs.occurredAt, rhs.occurredAt) {
            case let (left?, right?):
                return left > right
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return false
            }
        }
    }

    private static func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }

        if let date = ISO8601DateFormatter().date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: value)
    }
}
