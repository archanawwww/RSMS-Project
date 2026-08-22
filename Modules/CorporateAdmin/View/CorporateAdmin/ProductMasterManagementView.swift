import SwiftUI

struct ProductMasterManagementView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedCategory: String? = nil

    @State private var productToEdit: ProductMasterRecord? = nil
    @State private var preselectedCategory: String? = nil
    @State private var showProductEditor = false
    @State private var showProductDetails: ProductMasterRecord? = nil
    @State private var isRefreshing = false
    
    // Delete validation
    @State private var productToDelete: ProductMasterRecord? = nil
    @State private var show2FADelete = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var categoryFilters: [String] {
        let fromProducts = Set(authManager.productMasterRecords.map(\.category).filter { !$0.isEmpty })
        let fromLocal = Set(authManager.itemCategories.map(\.name))
        return Array(fromProducts.union(fromLocal)).sorted()
    }

    var body: some View {
        ZStack {
            MatteTheme.Colors.dashboardBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    searchBar
                        .padding(.horizontal, 16)

                    categoryFilterScrollView

                    if isRefreshing && authManager.productMasterRecords.isEmpty {
                        ProgressView("Loading products...")
                            .padding(.top, 40)
                    } else if filteredProducts.isEmpty {
                        emptyStateView
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredProducts) { product in
                                ProductGlassCard(
                                    product: product,
                                    onSelect: {
                                        showProductDetails = product
                                    }
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: filteredProducts)
                    }

                    Spacer(minLength: 80)
                }
                .padding(.top, 16)
            }

            floatingAddButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Operations")
                    }
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Product Master")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
        }
        .refreshable {
            await refreshProducts()
        }
        .task {
            await refreshProducts()
            await authManager.fetchPricingRules()
        }
        .navigationDestination(item: $showProductDetails) { product in
            ProductMasterDetailView(product: product)
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showProductEditor, onDismiss: {
            productToEdit = nil
            preselectedCategory = nil
        }) {
            ProductMasterEditorView(
                product: productToEdit,
                preselectedCategory: preselectedCategory
            ) { savedProduct in
                if productToEdit != nil {
                    authManager.updateProductMasterRecord(savedProduct)
                } else {
                    authManager.addProductMasterRecord(savedProduct)
                }
                selectedCategory = savedProduct.category
                productToEdit = nil
                preselectedCategory = nil
            }
            .environmentObject(authManager)
        }
        .sheet(isPresented: $show2FADelete) {
            if let product = productToDelete {
                TwoFactorVerificationSheet(
                    title: "Confirm Deletion",
                    subtitle: "Permanently deletes '\(product.name)' from the catalog",
                    onSuccess: {
                        authManager.deleteProductMasterRecord(id: product.id)
                        show2FADelete = false
                        productToDelete = nil
                    }
                )
            }
        }
    }

    private func refreshProducts() async {
        isRefreshing = true
        await authManager.fetchProductMasterRecords()
        isRefreshing = false
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(MatteTheme.Colors.textSecondary)

            TextField("Search name, SKU, brand...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(MatteTheme.Colors.textPrimary)
                .font(.subheadline)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }

    private var categoryFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                filterPill(title: "All", isSelected: selectedCategory == nil) {
                    withAnimation { selectedCategory = nil }
                }

                ForEach(categoryFilters, id: \.self) { category in
                    filterPill(title: category, isSelected: selectedCategory == category) {
                        withAnimation { selectedCategory = category }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
    }

    private func filterPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isSelected ? MatteTheme.Colors.luxuryGold : Color.white)
                    .foregroundColor(isSelected ? .white : MatteTheme.Colors.textSecondary)
                    .cornerRadius(20)
                    .shadow(color: isSelected ? MatteTheme.Colors.luxuryGold.opacity(0.18) : Color.clear, radius: 4, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.clear : MatteTheme.Colors.borderLight, lineWidth: 1)
                    )
                
                // Gold underline indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(MatteTheme.Colors.luxuryGold)
                        .frame(width: 18, height: 2)
                } else {
                    Color.clear
                        .frame(width: 18, height: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    productToEdit = nil
                    preselectedCategory = selectedCategory
                    showProductEditor = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                        .background(
                            Circle()
                                .fill(MatteTheme.Colors.luxuryGold)
                        )
                        .shadow(color: MatteTheme.Colors.luxuryGold.opacity(0.4), radius: 10, x: 0, y: 6)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 50))
                .foregroundColor(MatteTheme.Colors.textTertiary)
                .padding(.top, 40)
            Text("No Products Found")
                .font(.headline)
                .foregroundColor(MatteTheme.Colors.textPrimary)
            Text("No products in the database match your search or filters.")
                .font(.caption)
                .foregroundColor(MatteTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var filteredProducts: [ProductMasterRecord] {
        authManager.productMasterRecords.filter { product in
            if product.isArchived { return false }

            if let selectedCategory,
               product.category.localizedCaseInsensitiveCompare(selectedCategory) != .orderedSame {
                return false
            }

            if !searchText.isEmpty {
                let term = searchText.lowercased()
                return product.name.lowercased().contains(term)
                    || product.sku.lowercased().contains(term)
                    || product.brand.lowercased().contains(term)
                    || product.description?.lowercased().contains(term) == true
            }

            return true
        }
    }
}

struct ProductGlassCard: View {
    let product: ProductMasterRecord
    let onSelect: () -> Void
    
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                if let imageURLString = product.imageURL, let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 130)
                                .clipped()
                                .cornerRadius(12)
                        case .failure, .empty:
                            fallbackMonogramBox
                        @unknown default:
                            fallbackMonogramBox
                        }
                    }
                } else {
                    fallbackMonogramBox
                }
            }
            .frame(height: 130)
            .padding(.horizontal, 8)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                // Status, SKU, Action Menu
                HStack(spacing: 4) {
                    // Status Pill
                    HStack(spacing: 4) {
                        Circle()
                            .fill(product.isActive ? MatteTheme.Colors.success : MatteTheme.Colors.textTertiary)
                            .frame(width: 5, height: 5)
                        Text(product.isActive ? "Active" : "Inactive")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(product.isActive ? MatteTheme.Colors.success : MatteTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(product.isActive ? MatteTheme.Colors.success.opacity(0.1) : Color.black.opacity(0.04))
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    // SKU
                    Text(product.sku)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    let subtitle = product.description ?? ""
                    Text(subtitle.isEmpty ? product.brand : subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Text(formattedPrice)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
        .onTapGesture(perform: onSelect)
    }

    private var fallbackMonogramBox: some View {
        ZStack {
            LinearGradient(
                colors: [categoryColor.opacity(0.18), categoryColor.opacity(0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(12)

            VStack {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundColor(categoryColor)
                    .shadow(color: categoryColor.opacity(0.3), radius: 4, y: 2)

                Text(product.brand.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary.opacity(0.6))
                    .kerning(1.0)
                    .padding(.top, 4)
            }
        }
    }

    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: product.price)) ?? "₹\(Int(product.price))"
    }

    private var categoryIcon: String {
        switch product.category.lowercased() {
        case "purses", "handbags", "leather goods": return "handbag"
        case "watches": return "clock"
        case "fragrances": return "sparkles"
        case "footwear", "sneakers": return "shoe"
        case "jewelry": return "sparkle"
        case "accessories": return "sunglasses"
        case "ready-to-wear": return "tshirt"
        default: return "shippingbox"
        }
    }

    private var categoryColor: Color {
        switch product.category.lowercased() {
        case "purses", "handbags", "leather goods": return MatteTheme.Colors.primaryGold
        case "watches": return MatteTheme.Colors.info
        case "fragrances": return MatteTheme.Colors.warning
        case "footwear", "sneakers": return MatteTheme.Colors.success
        default: return MatteTheme.Colors.textSecondary
        }
    }
}
