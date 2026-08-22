import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var summary: DashboardSummary?
    @Published var tasks: [DashboardTask] = []
    @Published var lowStockProducts: [Product] = []
    @Published var shipments: [Shipment] = []
    @Published var storeRequests: [StoreRequest] = []
    @Published var vendorRequests: [VendorRequest] = []

    private let dashboardRepository = DashboardRepository()
    private let productRepository = ProductRepository()
    private let shipmentRepository = ShipmentRepository()
    private let storeRequestRepository = StoreRequestRepository()
    private let vendorRequestRepository = VendorRequestRepository()

    func loadData() async {
        do {
            async let summaryTask = dashboardRepository.fetchSummary()
            async let tasksTask = dashboardRepository.fetchTasks()
            async let productsTask = productRepository.fetchInventoryProducts()
           
            async let shipmentsTask = shipmentRepository.fetchShipments()
            async let storeRequestsTask = storeRequestRepository.fetchStoreRequests()
            async let vendorRequestsTask = vendorRequestRepository.fetchVendorRequests()

            let (fetchedSummary, fetchedTasks, fetchedProducts, fetchedShipments, fetchedStoreRequests, fetchedVendorRequests) = try await (summaryTask, tasksTask, productsTask, shipmentsTask, storeRequestsTask, vendorRequestsTask)

            summary = fetchedSummary
            tasks = fetchedTasks
            lowStockProducts = fetchedProducts.filter(\.isLowStock)
            shipments = fetchedShipments
            storeRequests = fetchedStoreRequests
            vendorRequests = fetchedVendorRequests
        } catch {
            print("Error loading dashboard data: \(error)")
        }
    }

    // MARK: - Workflow card data

    var receiveDeliveryBadge: Int {
        shipments.filter { $0.status == .inTransit }.count
    }

    var receiveDeliverySKUs: Int {
        shipments.filter { $0.status == .inTransit }
            .compactMap { $0.itemsCount }
            .reduce(0, +)
    }

    var lowStockBadge: Int {
        lowStockProducts.count
    }

    var lowStockExamples: String {
        // Design spec: show only top 2 items. Do NOT append "+N more".
        let names = lowStockProducts.prefix(2).map(\.name)
        if names.isEmpty { return "" }
        return "Top affected\n" + names.joined(separator: "\n")
    }

    var cycleCountBadge: Int {
        tasks.filter { $0.taskType.lowercased().contains("cycle") }.count
    }

    var reviewRequestsBadge: Int {
        storeRequests.filter { $0.status == .pending }.count
    }

    var firstVendorRequestName: String {
        storeRequests.first(where: { $0.status == .pending })?.storeName ?? "Pending Approval"
    }

    var deliveries: [(vendorName: String, skuCount: Int, eta: String)] {
        let calendar = Calendar.current
        let now = Date()

        return shipments
            .filter { $0.status == .inTransit || $0.status == .dispatched }
            .sorted { $0.expectedDate < $1.expectedDate }
            .map { shipment in
                let eta = formatETA(shipment.expectedDate, from: now, calendar: calendar)
                return (shipment.vendorName, shipment.itemsCount ?? 24, eta)
            }
    }

    var forecastCount: Int {
        lowStockProducts.count
    }

    private func formatETA(_ date: Date, from now: Date, calendar: Calendar) -> String {
        let diff = calendar.dateComponents([.hour, .minute], from: now, to: date)
        if let hours = diff.hour, let minutes = diff.minute {
            if hours > 0 {
                return "In \(hours)h \(minutes)m"
            } else if minutes > 0 {
                return "In \(minutes)m"
            } else {
                return "Now"
            }
        }
        return ""
    }
}
