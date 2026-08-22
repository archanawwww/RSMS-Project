//import Foundation
//import Supabase
//
//class VendorRepository {
//    
//   
//        
//        func fetchVendors() async throws -> [Vendor] {
//            
//            do{
//                
//                let vendors: [Vendor] = try await SupabaseService.shared.client
//                    .from("vendors")
//                    .select()
//                    .execute()
//                    .value
//                print(vendors)
//                
//                return vendors
//            }catch{
//                print(error)
//                throw error
//            }
//        }
//    
//}
//

import Foundation
import Supabase

class VendorRepository {

    func fetchVendors() async throws -> [Vendor] {

        try await SupabaseService.shared.client
            .from("vendors")
            .select()
            .execute()
            .value
    }

}
