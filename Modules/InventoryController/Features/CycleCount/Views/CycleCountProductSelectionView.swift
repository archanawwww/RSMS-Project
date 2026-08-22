import SwiftUI

// MARK: - Product Selection Screen

struct CycleCountProductSelectionView: View {
    @Binding var selectedProductIDs: Set<String>
    @Binding var allInventorySelected: Bool

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = InventoryViewModel()
    @State private var searchText = ""

    // MARK: Helpers

    private var filteredProducts: [Product] {
        guard !searchText.isEmpty else { return viewModel.products }
        return viewModel.products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.sku.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func isSelected(_ product: Product) -> Bool {
        allInventorySelected || selectedProductIDs.contains(product.id.uuidString)
    }

    private func toggle(_ product: Product) {
        if allInventorySelected {
            // Move from "All" to individual — deselect this one product
            allInventorySelected = false
            selectedProductIDs = Set(viewModel.products.map { $0.id.uuidString })
            selectedProductIDs.remove(product.id.uuidString)
        } else if selectedProductIDs.contains(product.id.uuidString) {
            selectedProductIDs.remove(product.id.uuidString)
        } else {
            selectedProductIDs.insert(product.id.uuidString)
            // Auto-promote to "All Inventory" if every product is now checked
            if selectedProductIDs.count == viewModel.products.count {
                allInventorySelected = true
                selectedProductIDs.removeAll()
            }
        }
    }

    // MARK: Body

    var body: some View {
        List {

            // ── Pinned: Entire Inventory ─────────────────────────────────
            Section {
                Button {
                    allInventorySelected.toggle()
                    if !allInventorySelected {
                        selectedProductIDs.removeAll()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 17))
                            .foregroundColor(Color(UIColor.systemBlue))
                            .frame(width: 28, alignment: .center)

                        Text("Entire Inventory")
                            .font(.system(size: 17))
                            .foregroundColor(Color(UIColor.label))

                        Spacer()

                        if allInventorySelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(UIColor.systemBlue))
                        }
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color.theme.surface)

            // ── Product List ─────────────────────────────────────────────
            Section {
                ForEach(filteredProducts) { product in
                    Button {
                        toggle(product)
                    } label: {
                        HStack(spacing: 12) {
                            InventoryProductThumbnail(
                                imageUrl: product.imageUrl,
                                category: product.category,
                                size: 40
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.name)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(UIColor.label))
                                    .lineLimit(1)
                                Text(product.sku)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }

                            Spacer()

                            if isSelected(product) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(UIColor.systemBlue))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listRowBackground(Color.theme.surface)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.theme.backgroundGrouped.ignoresSafeArea())
        .searchable(text: $searchText, prompt: "Search Products")
        .navigationTitle("Products")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
            }
        }
        .task { await viewModel.fetchProducts() }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CycleCountProductSelectionView(
            selectedProductIDs: .constant([]),
            allInventorySelected: .constant(false)
        )
    }
}
