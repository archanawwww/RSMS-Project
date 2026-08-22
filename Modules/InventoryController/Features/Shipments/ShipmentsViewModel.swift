import SwiftUI
import Combine

enum ShipmentsTab: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case history = "History"
}

@MainActor
class ShipmentsViewModel: ObservableObject {
    @Published var selectedTab: ShipmentsTab = .active
    @Published var searchText: String = ""
    
    @Published var selectedStatuses: Set<FilterStatus> = []
    @Published var selectedETA: FilterETA? = nil
    @Published var isLoading = true
    
    // Variance Tracking
    @Published var shipmentsWithVariance: Set<String> = []
    
    @Published var shipments: [Shipment] = []
    
    @Published var vendorRequests: [VendorRequest] = []
    @Published var products: [Product] = []
    @Published var vendors: [Vendor] = []
    
    private let vendorRequestRepo = VendorRequestRepository()
    private let shipmentRepo = ShipmentRepository()
    private let vendorRepo = VendorRepository()
    private let productRepo = ProductRepository()
    private let asnRepo = ASNRepository()
    
    //    func loadData() async {
    //        self.isLoading = true
    //        // Load legacy mock data
    //        do {
    //
    //            products = try await productRepo.fetchProducts()
    //
    //            vendors = try await vendorRepo.fetchVendors()
    //
    //            shipments = try await shipmentRepo.fetchShipments()
    //
    //            vendorRequests = try await vendorRequestRepo.fetchVendorRequests()
    //
    //        } catch {
    //
    //            print("Error loading shipments data: \(error)")
    //
    //        }
    //        // Simulating network delay for skeleton loading
    //        try? await Task.sleep(nanoseconds: 800_000_000)
    //        self.isLoading = false
    //    }
    
    func loadData() async {
        isLoading = true
        
        do {
            products = try await productRepo.fetchProducts()
            print("✅ Products:", products.count)
        } catch {
            print("❌ Products Error:", error)
        }
        
        do {
            vendors = try await vendorRepo.fetchVendors()
            print("✅ Vendors:", vendors.count)
        } catch {
            print("❌ Vendors Error:", error)
        }
        
        do {
            shipments = try await shipmentRepo.fetchShipments()
            print("✅ Shipments:", shipments.count)
        } catch {
            print("❌ Shipments Error:", error)
        }
        
        do {
            vendorRequests = try await vendorRequestRepo.fetchVendorRequests()
            print("✅ Vendor Requests:", vendorRequests.count)
        } catch {
            print("❌ Vendor Requests Error:", error)
        }
        
        try? await Task.sleep(nanoseconds: 800_000_000)
        isLoading = false
    }
    
    // Derived properties for UI segments and search
    var activeFilterCount: Int {
        var count = 0
        if !selectedStatuses.isEmpty { count += selectedStatuses.count }
        if selectedETA != nil { count += 1 }
        return count
    }
    
    var filteredShipments: [Shipment] {
        let sourceList: [Shipment]
        
        switch selectedTab {
        case .all:
            sourceList = shipments
        case .active:
            sourceList = shipments.filter {
                $0.status == .inTransit ||
                $0.status == .awaitingReceipt ||
                $0.status == .processing ||
                $0.status == .exception ||
                $0.status == .dispatched ||
                $0.status == .created ||
                $0.status == .approved
            }
        case .history:
            sourceList = shipments.filter {
                $0.status == .completed ||
                $0.status == .returned ||
                $0.status == .cancelled ||
                $0.status == .received
            }
        }
        
        // 1. Filter by Status (In Transit, Arrived, Completed)
        let statusFilteredList = sourceList.filter { shipment in
            if selectedStatuses.isEmpty { return true }
            
            let isTransit = shipment.status == .inTransit || shipment.status == .dispatched
            let isArrived = shipment.status == .awaitingReceipt || shipment.status == .processing || shipment.status == .exception || shipment.status == .created || shipment.status == .approved
            let isCompleted = shipment.status == .completed || shipment.status == .received || shipment.status == .returned || shipment.status == .cancelled
            
            if selectedStatuses.contains(.inTransit) && isTransit { return true }
            if selectedStatuses.contains(.arrived) && isArrived { return true }
            if selectedStatuses.contains(.completed) && isCompleted { return true }
            
            return false
        }
        
        // 2. Filter by ETA
        let etaFilteredList = statusFilteredList.filter { shipment in
            guard let selectedETA = selectedETA else { return true }
            let cal = Calendar.current
            
            switch selectedETA {
            case .today:
                return cal.isDateInToday(shipment.expectedDate)
            case .tomorrow:
                return cal.isDateInTomorrow(shipment.expectedDate)
            case .thisWeek:
                return cal.isDate(shipment.expectedDate, equalTo: Date(), toGranularity: .weekOfYear)
            case .custom:
                return true // Placeholder logic
            }
        }
        
        if searchText.isEmpty {
            return etaFilteredList
        } else {
            let lowercasedSearch = searchText.lowercased()
            return etaFilteredList.filter {
                $0.id.lowercased().contains(lowercasedSearch) ||
                $0.vendorName.lowercased().contains(lowercasedSearch) ||
                ($0.asnNumber?.lowercased().contains(lowercasedSearch) ?? false)
            }
        }
    }
    
    func submitVendorRequest(
        sku: String,
        
        productName: String,
        
        quantity: Int,
        
        vendorName: String,
        
        needByDate: Date,
        
        reason: String,
        
        productId: UUID?,
        
        productImageURL: String?
        
        
        
    ) async {
        let newRequest = VendorRequest(
            id: "VR-\(Int.random(in: 1000...9999))",
            vendorName: vendorName,
            sku: sku,
            productName: productName,
            quantity: quantity,
            status: .created,
            needByDate: needByDate,
            createdAt: Date(),
            sourceRequestId: nil
        )
        
        do {
            try await vendorRequestRepo.createVendorRequest(newRequest)
            
            
            let shipment = Shipment(
                
                id: "SH-\(Int.random(in: 1000...9999))",
                
                vendorRequestID: newRequest.id,
                
                vendorName: vendorName,
                
                status: .created,
                
                expectedDate: needByDate,
                
                origin: nil,
                
                destination: nil,
                
                itemsCount: quantity,
                
                asnNumber: nil,
                
                carrier: nil,
                
                trackingNumber: nil,
                
                completedDate: nil,
                
                returnedDate: nil,
                
                cancelledDate: nil,
                
                exceptionIssue: nil
                
            )
            
            try await shipmentRepo.createShipment(shipment)
            
            let asn = ASN(
                id: UUID(),
                shipmentId: shipment.id,
                vendorName: vendorName,
                expectedDate: needByDate,
                status: "Pending",
                totalExpected: quantity,
                totalReceived: 0,
                createdAt: Date(),
                items: []
            )
            
            try await asnRepo.createASN(asn)
            let item = ASNItem(
                id: UUID(),
                asnId: asn.id.uuidString,
                productId: productId,
                sku: sku,
                productName: productName,
                productImageURL: productImageURL,
                expectedQuantity: quantity,
                receivedQuantity: 0
            )
            
            try await asnRepo.createASNItem(item)
            
            await loadData()
            
            Task {
                
                try? await Task.sleep(for: .seconds(30))
                
                try? await shipmentRepo.updateShipmentStatus(
                    shipmentId: shipment.id,
                    status: .dispatched
                )
                try? await shipmentRepo.updateDispatchTime(
                    shipmentId: shipment.id
                )
                
                await loadData()
                
                try? await Task.sleep(for: .seconds(30))
                
                try? await shipmentRepo.updateShipmentStatus(
                    shipmentId: shipment.id,
                    status: .inTransit
                )
                try? await shipmentRepo.updateInTransitTime(
                    shipmentId: shipment.id
                )
                
                await loadData()
                
                try? await Task.sleep(for: .seconds(30))
                
                try? await shipmentRepo.updateShipmentStatus(
                    shipmentId: shipment.id,
                    status: .awaitingReceipt
                )

                try? await shipmentRepo.updateArrivalTime(
                    shipmentId: shipment.id
                )

                await loadData()            }
        }
        
        catch {
            print(error)
        }
        
        
        
    }
    
    // MARK: - Local Updates
    func completeShipment(id: String, hasVariance: Bool) async {
        
        do {
            
            try await shipmentRepo.updateShipmentStatus(
                shipmentId: id,
                status: .completed
            )
            try await shipmentRepo.updateReceivedTime(
                shipmentId: id
            )
            
            await loadData()
            
            if hasVariance {
                shipmentsWithVariance.insert(id)
            } else {
                shipmentsWithVariance.remove(id)
            }
            
        } catch {
            print(error)
        }
    }
    
}
