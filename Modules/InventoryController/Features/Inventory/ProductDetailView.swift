import SwiftUI

// MARK: - Inventory Movement Model

struct InventoryMovement: Identifiable {
    let id = UUID()
    let delta: Int
    let description: String
    let occurredAt: Date?

    var isPositive: Bool { delta > 0 }

    var formattedLabel: String {
        "\(delta > 0 ? "+" : "")\(delta) \(description)"
    }

    var dateLabel: String {
        guard let occurredAt else { return "" }

        let calendar = Calendar.current
        if calendar.isDateInToday(occurredAt) {
            return "Today"
        }
        if calendar.isDateInYesterday(occurredAt) {
            return "Yesterday"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: occurredAt)
    }
}

// MARK: - Product Detail View

struct ProductDetailView: View {
    let product: Product

    @State private var stockThreshold = "1"

    // MARK: Body

    var body: some View {
        List {
            productHeaderSection
            inventoryDetailsSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.theme.backgroundGrouped.ignoresSafeArea())
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    // MARK: - Product Header

    private var productHeaderSection: some View {
        Section {
            VStack(spacing: 8) {
                InventoryProductThumbnail(
                    imageUrl: product.imageUrl,
                    category: product.category,
                    size: 100
                )

                VStack(spacing: 3) {
                    Text(product.name)
                        .font(.system(size: 22, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(UIColor.label))

                    Text(product.sku)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .listRowBackground(Color.theme.backgroundGrouped)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Product Details

    private var inventoryDetailsSection: some View {
        Section("Product Details") {
            ProductDetailInfoRow(label: "Brand", value: product.brand)
            ProductDetailInfoRow(label: "Category", value: product.category)
            ProductDetailInfoRow(label: "Available Stock", value: "\(product.currentStock ?? 0)")
            StockThresholdRow(value: $stockThreshold)
        }
        .listRowBackground(Color.theme.surface)
    }

}

// MARK: - Reusable Detail Row

private struct ProductDetailInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .lineLimit(1)
        }
    }
}

private struct StockThresholdRow: View {
    @Binding var value: String

    var body: some View {
        HStack {
            Text("Stock Threshold")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            TextField("1", text: $value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .frame(width: 80)
        }
    }
}

// MARK: - Preview
