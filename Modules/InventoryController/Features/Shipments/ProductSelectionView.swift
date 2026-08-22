import SwiftUI

struct ProductSelectionView: View {
    let products: [Product]
    var onSelect: ((Product) -> Void)?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredProducts: [Product] {
        if searchText.isEmpty { return products }
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.sku.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filteredProducts) { product in
            Button {
                onSelect?(product)
                dismiss()
            } label: {
                HStack(spacing: 16) {
                    // Product Image (with fallback)
                    AsyncImage(url: URL(string: product.imageUrl ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil {
                            fallbackImage
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    
                    // Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(product.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(product.sku)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.vertical, 4)
            }
        }
        .searchable(text: $searchText, prompt: "Search by name or SKU")
        .navigationTitle("Select Product")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var fallbackImage: some View {
        ZStack {
            Color.gray.opacity(0.1)
            Image(systemName: "photo")
                .foregroundColor(.gray)
        }
    }
}
