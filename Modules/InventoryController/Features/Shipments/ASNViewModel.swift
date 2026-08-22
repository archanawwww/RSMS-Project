import SwiftUI
import Combine


@MainActor
class ASNViewModel: ObservableObject {
    @Published var asn: ASN?
    @Published var isLoading = false
    @Published var error: String?
    
    private let repository = ASNRepository()
    
    func loadASN(shipmentId: String) async {

        isLoading = true
        error = nil

        do {

            let fetchedASN = try await repository.fetchASN(
                shipmentId: shipmentId
            )

            self.asn = fetchedASN

        } catch {

            self.error = error.localizedDescription
            print(error)

        }

        isLoading = false
    }
}
