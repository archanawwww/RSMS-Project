import SwiftUI

// MARK: - Pricing Rules View (Sprint 1)

/// Displays and manages product master record pricing and tax rules.
/// Allows dynamic editing of prices with tax computations.
struct PricingRulesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var editingProduct: ProductMasterRecord? = nil
    @State private var editPrice: String = ""
    @State private var editCost: String = ""
    @State private var editTax: String = ""
    @State private var showEditor = false
    
    // Search and Filters
    @State private var searchText = ""
    @State private var selectedBrand: String? = nil
    @State private var selectedCategory: String? = nil
    @State private var selectedStatus: String? = nil
    @State private var selectedMargin: String? = nil
    
    // 2FA
    @State private var show2FA = false
    @State private var pendingAction: (() -> Void)?
    
    private var brandsList: [String] {
        Array(Set(authManager.productMasterRecords.map(\.brand).filter { !$0.isEmpty })).sorted()
    }
    
    private var categoriesList: [String] {
        Array(Set(authManager.productMasterRecords.map(\.category).filter { !$0.isEmpty })).sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar & Filter Dropdowns
            VStack(spacing: 12) {
                searchBar
                    .padding(.horizontal, 16)
                
                filterDropdowns
            }
            .padding(.vertical, 14)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(filteredProducts) { product in
                        productPriceCard(for: product)
                    }
                    
                    if filteredProducts.isEmpty {
                        emptyStateView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 96)
            }
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationTitle("Pricing Rules")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showEditor) {
            priceEditorSheet
        }
        .sheet(isPresented: $show2FA) {
            TwoFactorVerificationSheet(
                title: "Verify to Modify Pricing",
                subtitle: "2FA required to update catalog pricing rules",
                onSuccess: {
                    pendingAction?()
                    pendingAction = nil
                }
            )
        }
        .task {
            await authManager.fetchProductMasterRecords()
            await authManager.fetchPricingRules()
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(MatteTheme.Colors.textSecondary)

            TextField("Search products, SKU or brand...", text: $searchText)
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
        .background(Color.black.opacity(0.03))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Filter Dropdowns
    private var filterDropdowns: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Brand Filter
                Menu {
                    Button("All Brands") { selectedBrand = nil }
                    ForEach(brandsList, id: \.self) { brand in
                        Button(brand) { selectedBrand = brand }
                    }
                } label: {
                    filterButtonLabel(title: selectedBrand ?? "Brand")
                }
                
                // Category Filter
                Menu {
                    Button("All Categories") { selectedCategory = nil }
                    ForEach(categoriesList, id: \.self) { cat in
                        Button(cat) { selectedCategory = cat }
                    }
                } label: {
                    filterButtonLabel(title: selectedCategory ?? "Category")
                }
                
                // Status Filter
                Menu {
                    Button("All Statuses") { selectedStatus = nil }
                    Button("Active") { selectedStatus = "Active" }
                    Button("Inactive") { selectedStatus = "Inactive" }
                } label: {
                    filterButtonLabel(title: selectedStatus ?? "Status")
                }
                
                // Margin Range Filter
                Menu {
                    Button("All Margins") { selectedMargin = nil }
                    Button("Low (< 20%)") { selectedMargin = "Low" }
                    Button("Medium (20% - 40%)") { selectedMargin = "Medium" }
                    Button("High (> 40%)") { selectedMargin = "High" }
                } label: {
                    filterButtonLabel(title: selectedMargin ?? "Margin Range")
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func filterButtonLabel(title: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
            Image(systemName: "chevron.down")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Product Price Card
    
    private func productPriceCard(for product: ProductMasterRecord) -> some View {
        // Find the matching pricing rule for this product
        let pricing = authManager.pricingRules.first { $0.productID == product.id }
        
        // Use pricing values if available, otherwise fall back to product values
        let rawCost = pricing?.costPrice ?? product.costPrice
        let rawPrice = pricing?.basePrice ?? product.price
        let rawTax = pricing?.tax ?? product.tax
        
        // Logic: Cost price cannot be zero. Default to 60% of base price if zero
        let costPrice = rawCost <= 0 ? (rawPrice * 0.6) : rawCost
        let basePrice = rawPrice
        let taxRate = rawTax
        
        // Calculations
        let taxRatePercent = taxRate / 100.0
        let preTax = basePrice / (1.0 + taxRatePercent)
        let taxAmount = basePrice - preTax
        
        // Markup % = (Pre-Tax Price - Cost) / Cost
        let markupPercent = costPrice > 0 ? ((preTax - costPrice) / costPrice) * 100.0 : 0.0
        
        // Gross Margin = Final Price - Cost
        let grossMarginAmount = basePrice - costPrice
        let grossMarginPercent = basePrice > 0 ? (grossMarginAmount / basePrice) * 100.0 : 0.0
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                // Product Image
                ZStack {
                    if let imageURLString = product.imageURL, let imageURL = URL(string: imageURLString) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            case .failure, .empty:
                                fallbackMonogramBox(product: product)
                            @unknown default:
                                fallbackMonogramBox(product: product)
                            }
                        }
                    } else {
                        fallbackMonogramBox(product: product)
                    }
                }
                .frame(width: 60, height: 60)
                
                // Product details
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(product.sku)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .lineLimit(1)
                        
                        Text("•")
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                        
                        Text(product.brand)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .lineLimit(1)
                        
                        Text("•")
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                        
                        // Status Badge
                        Text(product.isActive ? "Active" : "Inactive")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(product.isActive ? MatteTheme.Colors.success : MatteTheme.Colors.textSecondary)
                            .lineLimit(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(product.isActive ? MatteTheme.Colors.success.opacity(0.12) : Color.black.opacity(0.05))
                            .cornerRadius(4)
                    }
                }
                .layoutPriority(1)
                
                Spacer()
                
                // Action Buttons
                Button {
                    require2FA {
                        editingProduct = product
                        editPrice = String(format: "%.0f", basePrice)
                        editCost = String(format: "%.0f", costPrice)
                        editTax = String(format: "%.0f", taxRate)
                        showEditor = true
                    }
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                        .frame(width: 28, height: 28)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Metrics grid
            HStack(spacing: 0) {
                // Cost Price
                metricColumn(label: "Cost Price", value: formatPrice(costPrice))
                
                verticalDivider
                
                // Markup %
                metricColumn(label: "Markup", value: String(format: "+%.1f%%", markupPercent), valueColor: MatteTheme.Colors.primaryGold)
                
                verticalDivider
                
                // Pre-Tax
                metricColumn(label: "Pre-Tax Price", value: formatPrice(preTax))
                
                verticalDivider
                
                // Tax (18%)
                metricColumn(label: "Tax (\(Int(taxRate))%)", value: formatPrice(taxAmount))
                
                verticalDivider
                
                // Final Price
                VStack(spacing: 4) {
                    Text("Final Price")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    Text(formatPrice(basePrice))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(MatteTheme.Colors.primaryGold.opacity(0.08))
                .cornerRadius(10)
            }
            .padding(.top, 4)
            
            // Gross Margin Sparkline
            HStack(spacing: 6) {
                Image(systemName: "line.diagonal.arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.success)
                
                Text("Gross Margin:")
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                
                Text("\(formatPrice(grossMarginAmount)) (\(String(format: "%.1f%%", grossMarginPercent)))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.success)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    private func metricColumn(label: String, value: String, valueColor: Color = .black) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var verticalDivider: some View {
        Rectangle()
            .fill(MatteTheme.Colors.borderLight)
            .frame(width: 1, height: 26)
    }
    
    private func fallbackMonogramBox(product: ProductMasterRecord) -> some View {
        ZStack {
            Color.black.opacity(0.04)
                .cornerRadius(8)
            Image(systemName: "shippingbox.fill")
                .font(.title3)
                .foregroundColor(MatteTheme.Colors.primaryGold)
        }
    }
    

    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "indianrupeesign.circle")
                .font(.system(size: 48))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            Text("No matching pricing rules found.")
                .font(.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var filteredProducts: [ProductMasterRecord] {
        authManager.productMasterRecords.filter { product in
            // Search Text
            if !searchText.isEmpty {
                let term = searchText.lowercased()
                if !product.name.lowercased().contains(term) &&
                   !product.sku.lowercased().contains(term) &&
                   !product.brand.lowercased().contains(term) {
                    return false
                }
            }
            
            // Brand
            if let selectedBrand, product.brand != selectedBrand {
                return false
            }
            
            // Category
            if let selectedCategory, product.category != selectedCategory {
                return false
            }
            
            // Status
            if let selectedStatus {
                let isActive = selectedStatus == "Active"
                if product.isActive != isActive {
                    return false
                }
            }
            
            // Margin Range
            if let selectedMargin {
                let pricing = authManager.pricingRules.first { $0.productID == product.id }
                let rawPrice = pricing?.basePrice ?? product.price
                let rawCost = pricing?.costPrice ?? product.costPrice
                let cost = rawCost <= 0 ? (rawPrice * 0.6) : rawCost
                let margin = rawPrice > 0 ? ((rawPrice - cost) / rawPrice) * 100.0 : 0.0
                
                switch selectedMargin {
                case "Low":
                    if margin >= 20.0 { return false }
                case "Medium":
                    if margin < 20.0 || margin > 40.0 { return false }
                case "High":
                    if margin <= 40.0 { return false }
                default:
                    break
                }
            }
            
            return true
        }
    }
    
    // MARK: - Price Editor Sheet
    
    private var priceEditorSheet: some View {
        NavigationStack {
            Form {
                if let product = editingProduct {
                    Section(header: Text("Product")) {
                        Text(product.name)
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .fontWeight(.medium)
                        Text(product.sku)
                            .font(.caption.monospaced())
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                }
                
                Section(header: Text("Pricing Details (INR)")) {
                    HStack {
                        Text("Cost Price")
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        Spacer()
                        TextField("Cost", text: $editCost)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Final Retail Price")
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        Spacer()
                        TextField("Price", text: $editPrice)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Modify Pricing Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showEditor = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePricingChanges()
                        showEditor = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func savePricingChanges() {
        guard var product = editingProduct else { return }
        
        let priceVal = Double(editPrice) ?? 0
        let costVal = Double(editCost) ?? 0
        let taxVal = product.tax > 0 ? product.tax : 18.0
        
        // Update product record
        product.price = priceVal
        product.costPrice = costVal
        product.tax = taxVal
        product.updatedAt = Date()
        
        // Update both Product and Pricing tables in Supabase
        Task {
            do {
                // First update the product and await its database write
                try await SupabaseAuthService.shared.updateProduct(product: product)
                
                // Add audit log for product update
                let oldRecord = authManager.productMasterRecords.first(where: { $0.id == product.id })
                if let oldRecord {
                    let encoder = JSONEncoder()
                    let oldStr = (try? encoder.encode(oldRecord)).flatMap { String(data: $0, encoding: .utf8) }
                    let newStr = (try? encoder.encode(product)).flatMap { String(data: $0, encoding: .utf8) }
                    authManager.logAuditAction(
                        action: .update,
                        tableName: "Product",
                        recordID: product.id,
                        previousValues: oldStr,
                        newValues: newStr
                    )
                }
                
                // Then update or create pricing
                if let existingPricing = authManager.pricingRules.first(where: { $0.productID == product.id }) {
                    let updatedPricing = SupabasePricing(
                        id: existingPricing.id,
                        productID: product.id,
                        costPrice: costVal,
                        basePrice: priceVal,
                        tax: taxVal,
                        isActive: true,
                        createdAt: existingPricing.createdAt,
                        updatedAt: Date()
                    )
                    try await SupabaseAuthService.shared.updatePricing(pricing: updatedPricing)
                } else {
                    let newPricing = SupabasePricing(
                        id: UUID(),
                        productID: product.id,
                        costPrice: costVal,
                        basePrice: priceVal,
                        tax: taxVal,
                        isActive: true,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    try await SupabaseAuthService.shared.createPricing(pricing: newPricing)
                }
                
                // Refresh data
                await authManager.fetchProductMasterRecords()
                await authManager.fetchPricingRules()
            } catch {
                print("Failed to save pricing changes: \(error)")
            }
        }
    }
    
    private func require2FA(action: @escaping () -> Void) {
        pendingAction = action
        show2FA = true
    }
    
    private func formatPrice(_ amount: Double) -> String {
        if amount >= 1000 {
            let kVal = amount / 1000.0
            if kVal == floor(kVal) {
                return String(format: "₹%.0fk", kVal)
            } else {
                return String(format: "₹%.1fk", kVal)
            }
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "₹"
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount)) ?? "₹\(Int(amount))"
        }
    }
}
