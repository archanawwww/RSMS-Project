import Foundation
import Supabase

struct InventoryStockInsert: Encodable {

    let product_id: UUID

    let current_stock: Int

    let reserved_stock: Int

    let damaged_stock: Int

    let reorder_threshold: Int

}

class ASNRepository {

    func createASN(_ asn: ASN) async throws {

        try await SupabaseService.shared.client

            .from("asns")

            .insert(asn)

            .execute()

    }

    // MARK: Create ASN Item

    func createASNItem(_ item: ASNItem) async throws {
        
        try await SupabaseService.shared.client
        
            .from("asn_items")
        
            .insert(item)
        
            .execute()
        
    }

    // Fetch ASN using Shipment ID
    func fetchASN(shipmentId: String) async throws -> ASN {

        var asn: ASN = try await SupabaseService.shared.client
            .from("asns")
            .select()
            .eq("shipment_id", value: shipmentId)
            .single()
            .execute()
            .value

        // Fetch ASN Items
        let items: [ASNItem] = try await fetchASNItems(asnId: asn.id.uuidString)

        asn.items = items

        return asn
    }

    // Fetch ASN Items
    func fetchASNItems(asnId: String) async throws -> [ASNItem] {

        let items: [ASNItem] = try await SupabaseService.shared.client
            .from("asn_items")
            .select()
            .eq("asn_id", value: asnId)
            .execute()
            .value

        return items
    }
    
    func updateASNTotals(
        asnId: UUID,
        totalReceived: Int
    ) async throws {

        try await SupabaseService.shared.client
            .from("asns")
            .update([
                "total_received": totalReceived
            ])
            .eq("id", value: asnId.uuidString)
            .execute()
    }

    func updateASNItems(
        items: [ASNItem]
    ) async throws {

        for item in items {

            try await SupabaseService.shared.client
                .from("asn_items")
                .update([
                    "received_quantity": item.receivedQuantity
                ])
                .eq("id", value: item.id.uuidString)
                .execute()
        }
    }
    
    // MARK: Update ASN

    func updateASN(asn: ASN) async throws {

        try await SupabaseService.shared.client
            .from("asns")
            .update([
                "total_received": asn.totalReceived
            ])
            .eq("id", value: asn.id.uuidString)
            .execute()
    }

    // MARK: Update ASN Items

    func updateInventoryStock(items: [ASNItem]) async throws {

        struct InventoryStock: Codable {
            let id: UUID
            let current_stock: Int
        }

        for item in items {

            guard let productId = item.productId else { continue }

            let existing: [InventoryStock] = try await SupabaseService.shared.client
                .from("inventory_stock")
                .select("id,current_stock")
                .eq("product_id", value: productId.uuidString)
                .execute()
                .value

            if let stock = existing.first {

                try await SupabaseService.shared.client
                    .from("inventory_stock")
                    .update([
                        "current_stock": stock.current_stock + item.receivedQuantity
                    ])
                    .eq("id", value: stock.id.uuidString)
                    .execute()

            } else {

                try await SupabaseService.shared.client
                    .from("inventory_stock")
//                    .insert([
//                        "product_id": productId.uuidString,
//                        "current_stock": item.receivedQuantity,
//                        "reserved_stock": 0,
//                        "damaged_stock": 0,
//                        "reorder_threshold": 10
//                    ])
                
                let row = InventoryStockInsert(
                    product_id: productId,
                    current_stock: item.receivedQuantity,
                    reserved_stock: 0,
                    damaged_stock: 0,
                    reorder_threshold: 10
                )

                try await SupabaseService.shared.client
                    .from("inventory_stock")
                    .insert(row)
                    .execute()

            }
        }
    }

}
