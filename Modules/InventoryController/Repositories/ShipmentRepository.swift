//import Foundation
//import Supabase
//
//class ShipmentRepository {
//
//    func fetchShipments() async throws -> [Shipment] {
//
//        let shipments: [Shipment] = try await SupabaseService.shared.client
//            .from("shipments")
//            .select()
//            .execute()
//            .value
//
//        return shipments
//    }
//}


import Foundation
import Supabase

class ShipmentRepository {

    func fetchShipments() async throws -> [Shipment] {

        let shipments: [Shipment] = try await SupabaseService.shared.client
            .from("shipments")
            .select()
            .execute()
            .value

        return shipments
    }
    
    func createShipment(_ shipment: Shipment) async throws {

        try await SupabaseService.shared.client
            .from("shipments")
            .insert(shipment)
            .execute()
    }
    
    func updateShipmentStatus(
        shipmentId: String,
        status: ShipmentStatus
    ) async throws {

        try await SupabaseService.shared.client
            .from("shipments")
            .update([
                "status": status.rawValue
            ])
            .eq("id", value: shipmentId)
            .execute()
    }
    
    func updateArrivalTime(
        shipmentId: String,
        date: Date = Date()
    ) async throws {

        try await SupabaseService.shared.client
            .from("shipments")
            .update([
                "arrived_at": date.ISO8601Format()
            ])
            .eq("id", value: shipmentId)
            .execute()
    }
    
    func updateReceivedTime(
        shipmentId: String,
        date: Date = Date()
    ) async throws {

        try await SupabaseService.shared.client
            .from("shipments")
            .update([
                "received_at": date.ISO8601Format()
            ])
            .eq("id", value: shipmentId)
            .execute()
    }
    
    func updateDispatchTime(
        shipmentId: String
    ) async throws {

        try await SupabaseService.shared.client
            .from("shipments")
            .update([
                "dispatched_at": ISO8601DateFormatter().string(from: Date())
            ])
            .eq("id", value: shipmentId)
            .execute()
    }
    
    func updateInTransitTime(
        shipmentId: String
    ) async throws {

        try await SupabaseService.shared.client
            .from("shipments")
            .update([
                "in_transit_at": ISO8601DateFormatter().string(from: Date())
            ])
            .eq("id", value: shipmentId)
            .execute()
    }
}
