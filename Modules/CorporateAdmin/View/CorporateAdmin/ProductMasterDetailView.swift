import SwiftUI

struct ProductMasterDetailView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State var product: ProductMasterRecord
    
    @State private var showProductEditor = false
    @State private var show2FADelete = false
    

    
    var body: some View {
        ZStack {
            MatteTheme.Colors.dashboardBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Premium Header Banner Card
                    headerCardView
                    
                    // Detailed Information List with Circular Icons
                    detailsCardView
                    
                    // Status segmented control toggle
                    statusToggle
                    
                    // Large Edit Product button
                    editProductButton
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(product.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: archiveProduct) {
                        Label("Archive Product", systemImage: "archivebox")
                    }
                    
                    Button(role: .destructive, action: { show2FADelete = true }) {
                        Label("Delete Product", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.04))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showProductEditor) {
            ProductMasterEditorView(product: product) { savedProduct in
                authManager.updateProductMasterRecord(savedProduct)
                product = savedProduct
                showProductEditor = false
            }
            .environmentObject(authManager)
        }
        .sheet(isPresented: $show2FADelete) {
            TwoFactorVerificationSheet(
                title: "Confirm Deletion",
                subtitle: "Permanently deletes '\(product.name)' from the catalog",
                onSuccess: {
                    authManager.deleteProductMasterRecord(id: product.id)
                    show2FADelete = false
                    dismiss()
                }
            )
        }
    }
    
    // MARK: - Product Actions
    
    private func archiveProduct() {
        var updated = product
        updated.isArchived = true
        authManager.updateProductMasterRecord(updated)
        product = updated
        dismiss()
    }
    
    // MARK: - Header Card View (Visual Product Banner)
    
    private var headerCardView: some View {
        HStack(spacing: 16) {
            ZStack {
                if let imageURLString = product.imageURL, let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
            .frame(width: 100, height: 100)
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(product.brand.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                    .kerning(1.5)
                
                Text(product.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Status Pill
                    HStack(spacing: 4) {
                        Circle()
                            .fill(product.isActive ? MatteTheme.Colors.success : MatteTheme.Colors.textTertiary)
                            .frame(width: 5, height: 5)
                        Text(product.isActive ? "Active" : "Inactive")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(product.isActive ? MatteTheme.Colors.success : MatteTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(product.isActive ? MatteTheme.Colors.success.opacity(0.12) : Color.black.opacity(0.05))
                    .cornerRadius(6)
                    
                    // SKU Badge
                    Text(product.sku)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MatteTheme.Colors.primaryGold.opacity(0.12))
                        .cornerRadius(6)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Details List View
    
    private var detailsCardView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PRODUCT IDENTITY & FINANCIALS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.luxuryGold)
                .kerning(1.2)
                .padding(.bottom, 4)
            
            detailRow(icon: "tag.fill", title: "Brand", value: product.brand)
            Divider()
            detailRow(icon: "square.grid.2x2.fill", title: "Category", value: product.category.isEmpty ? "Uncategorized" : product.category)
            Divider()
            detailRow(icon: "number", title: "SKU Code", value: product.sku)
            Divider()
            detailRow(icon: "barcode", title: "Barcode (EAN-13)", value: product.barcode.isEmpty ? "Not Assigned" : product.barcode)
            Divider()
            
            let pricing = authManager.pricingRules.first { $0.productID == product.id }
            let displayPrice = pricing?.basePrice ?? product.price
            let displayCost = pricing?.costPrice ?? product.costPrice
            let displayTax = pricing?.tax ?? product.tax
            
            detailRow(icon: "indianrupeesign", title: "Corporate Price (Retail)", value: formatPrice(displayPrice))
            Divider()
            detailRow(icon: "briefcase.fill", title: "Cost Price (HQ)", value: formatPrice(displayCost))
            Divider()
            detailRow(icon: "percent", title: "Tax Rate", value: "\(Int(displayTax))%")
            
            if let desc = product.description, !desc.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Status Toggle
    private var statusToggle: some View {
        HStack(spacing: 12) {
            Button(action: {
                if !product.isActive {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    var updated = product
                    updated.isActive = true
                    authManager.updateProductMasterRecord(updated)
                    product = updated
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(product.isActive ? .white : MatteTheme.Colors.textSecondary)
                    Text("Active")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(product.isActive ? .white : MatteTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(product.isActive ? MatteTheme.Colors.success : Color.black.opacity(0.04))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                if product.isActive {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    var updated = product
                    updated.isActive = false
                    authManager.updateProductMasterRecord(updated)
                    product = updated
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(!product.isActive ? .white : MatteTheme.Colors.textSecondary)
                    Text("Inactive")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(!product.isActive ? .white : MatteTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(!product.isActive ? MatteTheme.Colors.textSecondary : Color.black.opacity(0.04))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Edit Product Button
    private var editProductButton: some View {
        Button(action: {
            showProductEditor = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .bold))
                Text("Edit Product")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(MatteTheme.Colors.luxuryGold)
            .cornerRadius(12)
            .shadow(color: MatteTheme.Colors.luxuryGold.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
    


    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.luxuryGold)
                .frame(width: 24, height: 24)
                .background(MatteTheme.Colors.luxuryGold.opacity(0.12))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textPrimary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatPrice(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₹\(Int(amount))"
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

                Text(product.brand.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary.opacity(0.6))
                    .kerning(1.0)
                    .padding(.top, 4)
            }
        }
    }

    private var categoryIcon: String {
        switch product.category.lowercased() {
        case "purses", "handbags", "leather goods": return "handbag"
        case "watches": return "clock"
        case "fragrances": return "sparkles"
        case "footwear", "sneakers": return "shoe"
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
