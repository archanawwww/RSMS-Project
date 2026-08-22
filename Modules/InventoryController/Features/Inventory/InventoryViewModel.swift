import Foundation
import Combine

enum InventoryCategoryFilter: String, CaseIterable, Identifiable {
    case fragrance = "Fragrance"
    case handBags = "Hand Bags"
    case watches = "Watches"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .fragrance: return "sparkles"
        case .handBags: return "bag"
        case .watches: return "watch.analog"
        }
    }

    func matches(_ product: Product) -> Bool {
        let category = product.category.lowercased()
        let sku = product.sku.lowercased()
        let name = product.name.lowercased()

        switch self {
        case .fragrance:
            return category.contains("fragrance")
                || category.contains("perfume")
                || sku.contains("per")
                || name.contains("fragrance")
                || name.contains("perfume")
                || name.contains("coco")
        case .handBags:
            return category.contains("hand bag")
                || category.contains("handbag")
                || category.contains("bag")
                || sku.contains("bag")
                || name.contains("bag")
                || name.contains("handbag")
        case .watches:
            return category.contains("watch")
                || sku.contains("wat")
                || name.contains("watch")
                || name.contains("rolex")
                || name.contains("cartier")
        }
    }
}

@MainActor
class InventoryViewModel: ObservableObject {
    private let repository = ProductRepository()
    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var selectedCategory: InventoryCategoryFilter?
    @Published var lowStockOnly = false

    var filteredProducts: [Product] {
        products.filter { product in
            let matchesSearch = searchText.isEmpty
                || product.name.localizedCaseInsensitiveContains(searchText)
                || product.sku.localizedCaseInsensitiveContains(searchText)

            let matchesCategory = selectedCategory?.matches(product) ?? true

            let matchesAvailability = !lowStockOnly || product.isLowStock

            return matchesSearch && matchesCategory && matchesAvailability
        }
    }

    func fetchProducts() async {

        isLoading = true

        do {

            products = try await repository.fetchInventoryProducts()

        } catch {

            print(error)

            products = []

        }

        isLoading = false
    }
}
