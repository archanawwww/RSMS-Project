import Foundation
import Supabase

class VendorRequestRepository {

    func fetchVendorRequests() async throws -> [VendorRequest] {

        let requests: [VendorRequest] = try await SupabaseService.shared.client
            .from("vendor_requests")
            .select()
            .execute()
            .value

        return requests
    }

    func createVendorRequest(_ request: VendorRequest) async throws {

        try await SupabaseService.shared.client
            .from("vendor_requests")
            .insert(request)
            .execute()

    }

}
