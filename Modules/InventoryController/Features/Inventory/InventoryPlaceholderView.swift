import SwiftUI

// MARK: - Main Inventory View

struct InventoryPlaceholderView: View {
    @EnvironmentObject var appState: InventoryAppState
    @StateObject private var viewModel = InventoryViewModel()
    @State private var isFilterSheetPresented = false

    // MARK: Derived list count
    private var productCount: Int { viewModel.filteredProducts.count }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {


                // ── Search row ─────────────────────────────────────────────
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(.system(size: 15))
                    TextField(
                        "Search Products",
                        text: $viewModel.searchText
                    )
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor.label))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(.horizontal, 10)
                .frame(height: 36)
                .background(Color.theme.backgroundSecondary)
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

                // ── Content ───────────────────────────────────────────────
                InventoryListView(products: viewModel.filteredProducts)
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Inventory")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isFilterSheetPresented = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(Color.theme.brand)
                    }
                }
            }
            .navigationDestination(item: $appState.activeCycleCountSession) { session in
                CycleCountExecutionView(session: session)
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                InventoryFilterSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchProducts()
            }
        }
    }
}

// MARK: - List Container

private struct InventoryListView: View {
    let products: [Product]

    var body: some View {
        List {

            if products.isEmpty {

                VStack(spacing:16){

                    Image(systemName:"shippingbox")

                        .font(.system(size:55))

                        .foregroundColor(.gray)

                    Text("No Inventory")

                        .font(.headline)

                    Text("Products received through ASN will appear here.")

                        .foregroundColor(.secondary)

                }

                .frame(maxWidth:.infinity)

                .padding(.vertical,120)

                .listRowSeparator(.hidden)

            }

            else{

                ForEach(products){ product in

                    NavigationLink(destination: ProductDetailView(product: product)){

                        InventoryProductRow(product: product)

                    }

                }

            }

        }
        .listStyle(.plain)
        .background(Color.theme.background)
    }
}

// MARK: - Product Row

struct InventoryProductRow: View {
    let product: Product

//    private var isLowStock: Bool {
//        product.currentStock <= product.reorderThreshold
//    }

    var body: some View {
        HStack(spacing: 14) {

            // Thumbnail ──────────────────────────────────────────────────
            InventoryProductThumbnail(
                imageUrl: product.imageUrl,
                category: product.category,
                size: 60
            )

            // Name + SKU ─────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text(product.sku)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }

            Spacer()

            // Quantity + status ───────────────────────────────────────────
//            VStack(alignment: .trailing, spacing: 2) {
//                Text("\(product.currentStock)")
//                    .font(.system(size: 24, weight: .bold))
//                    .foregroundColor(Color(UIColor.label))
//                    .monospacedDigit()
//
//                Text(isLowStock ? "Low stock" : "In stock")
//                    .font(.system(size: 13, weight: .regular))
//                    .foregroundColor(isLowStock ? .red : Color(UIColor.secondaryLabel))
//            }
            
            VStack(alignment: .trailing, spacing: 4) {

                Text("\(product.currentStock ?? 0)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                    .monospacedDigit()

                Text("Qty")
                    .font(.system(size: 13))
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            .frame(minWidth: 48, alignment: .trailing)
        }
        .padding(.vertical, 11)
        // Inset separator so it aligns with product name text, not the image
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            16 + 60 + 14   // leading padding + image width + spacing
        }
    }
}

// MARK: - Product Thumbnail

struct InventoryProductThumbnail: View {
    let imageUrl: String?
    let category: String?
    var size: CGFloat = 52               // override for larger contexts

    private var iconSize: CGFloat  { size * 0.42 }
    private var radius: CGFloat    { max(8, size * 0.14) }

    // Map category strings to contextual SF Symbols
    private var categorySymbol: String {
        switch category?.lowercased() {
        case "watch", "watches":          return "watch.analog"
        case "bag", "bags", "handbag":    return "bag"
        case "shoe", "shoes", "footwear": return "shoeprints.fill"
        case "jewellery", "jewelry":      return "sparkles"
        default:                          return "shippingbox"
        }
    }

    var body: some View {
        Group {
            if let urlStr = imageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit()
                    default:
                        symbolFallback
                    }
                }
            } else {
                symbolFallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    private var symbolFallback: some View {
        ZStack {
            Color(UIColor.systemGray6)
            Image(systemName: categorySymbol)
                .font(.system(size: iconSize))
                .foregroundColor(Color(UIColor.systemGray2))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Filter Sheet

struct InventoryFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: InventoryViewModel

    @State private var selectedCategory: InventoryCategoryFilter?
    @State private var lowStockOnly: Bool

    init(viewModel: InventoryViewModel) {
        self.viewModel = viewModel
        _selectedCategory = State(initialValue: viewModel.selectedCategory)
        _lowStockOnly = State(initialValue: viewModel.lowStockOnly)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Category") {
                    ForEach(InventoryCategoryFilter.allCases) { category in
                        filterRow(
                            title: category.rawValue,
                            systemImage: category.systemImage,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
                Section("Availability") {
                    filterRow(
                        title: "Low Stock",
                        systemImage: "exclamationmark.triangle",
                        isSelected: lowStockOnly
                    ) {
                        lowStockOnly.toggle()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .tint(Color.theme.brand)
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.selectedCategory = selectedCategory
                        viewModel.lowStockOnly = lowStockOnly
                        dismiss()
                    }
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.brand)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(16)
    }

    private func filterRow(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .frame(width: 24)
                    .foregroundColor(Color.theme.brand)

                Text(title)
                    .foregroundColor(Color.theme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.brand)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    InventoryPlaceholderView()
}
