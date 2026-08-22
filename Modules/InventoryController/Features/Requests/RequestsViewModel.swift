import SwiftUI
import Combine

@MainActor
class RequestsViewModel: ObservableObject {
    @Published var requests: [StoreRequest] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: RequestStatus? = .pending
    @Published var errorMessage: String?
    
    private let repository = StoreRequestRepository()
    
//    func loadRequests() async {
//        do {
//            requests = try await repository.fetchStoreRequests()
//        } catch {
//            print("Error loading store requests: \(error)")
//        }
//    }
    
    func loadRequests() async {
        
//        if let mockRequests = try? MockDataService.shared.load("store_requests", as: [StoreRequest].self) {
//            self.requests = mockRequests
//            print("COUNT =", requests.count)
//            return
//        }

        do {

            let requests = try await repository.fetchStoreRequests()

            print("COUNT =", requests.count)

            self.requests = requests

        } catch {

            print("ERROR =", error)

        }
    }
    
    var filteredRequests: [StoreRequest] {
        requests.filter { request in
            let matchesSearch = searchText.isEmpty || request.storeName.localizedCaseInsensitiveContains(searchText) || request.productName.localizedCaseInsensitiveContains(searchText) || request.id.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = selectedFilter == nil
                || request.status == selectedFilter
                || (selectedFilter == .fulfilled && request.status.matchesApprovedFilter)
            return matchesSearch && matchesStatus
        }
    }
    
    func approveRequest(_ request: StoreRequest) async -> Bool {

        do {
            try await repository.approveRequest(id: request.id)
            setStatus(.fulfilled, forRequestId: request.id)
            selectedFilter = .fulfilled
            await loadRequests()
            return true
        } catch {
            let message = "Error approving request: \(error.localizedDescription)"
            errorMessage = message
            print(message)
            return false
        }

    }

    func rejectRequest(_ request: StoreRequest, reason: String) async -> Bool {

        do {
            try await repository.rejectRequest(id: request.id)
            setStatus(.rejected, forRequestId: request.id)
            selectedFilter = .rejected
            await loadRequests()
            return true
        } catch {
            let message = "Error rejecting request: \(error.localizedDescription)"
            errorMessage = message
            print(message)
            return false
        }

    }

    func request(withId id: String) -> StoreRequest? {
        requests.first { $0.id == id }
    }

    private func setStatus(_ status: RequestStatus, forRequestId id: String) {
        guard let index = requests.firstIndex(where: { $0.id == id }) else { return }
        requests[index].status = status
    }
    
    
}
