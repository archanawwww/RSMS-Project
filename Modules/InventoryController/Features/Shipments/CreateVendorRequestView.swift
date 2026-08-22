import SwiftUI

struct RequestedProduct: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int = 1
}

struct CreateVendorRequestView: View {
    let prefilledRequest: StoreRequest?
    @EnvironmentObject var viewModel: ShipmentsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var requestedProducts: [RequestedProduct] = []
    @State private var selectedVendorId: String = ""
    @State private var needByDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var reason: String = ""
    @State private var showingProductSelection = false
    
    var totalQuantity: Int {
        requestedProducts.reduce(0) { $0 + $1.quantity }
    }
    
    var isFormValid: Bool {
        !requestedProducts.isEmpty && !selectedVendorId.isEmpty
    }
    
    var body: some View {
        Form {
            // Request Information
            Section(header: Text("Request Information").font(Typography.headline).foregroundColor(.primary)) {
                Picker("Vendor", selection: $selectedVendorId) {
                    Text("Select Vendor").tag("")
                    ForEach(viewModel.vendors) { vendor in
                        Text(vendor.name).tag(vendor.id)
                    }
                }
            }
            
            // Products Section
            Section(header: Text("Products (\(requestedProducts.count))").font(Typography.headline).foregroundColor(.primary)) {
//                ForEach($requestedProducts) { $item in
                ForEach($requestedProducts, id: \.id) { $item in
                    HStack(alignment: .center, spacing: Spacing.standard) {
                        // Product Image
                        AsyncImage(url: URL(string: item.product.imageUrl ?? "")) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else if phase.error != nil {
                                ZStack { Color.gray.opacity(0.1); Image(systemName: "photo").foregroundColor(.gray) }
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product.name)
                                .font(Typography.body.weight(.medium))
                                .foregroundColor(.primary)
                            Text("SKU: \(item.product.sku)")
                                .font(Typography.caption)
                                .foregroundColor(Color.theme.textSecondary)
                            Text(item.product.category)
                                .font(Typography.caption)
                                .foregroundColor(Color.theme.textTertiary)
                            Text(item.product.brand)
                                .font(Typography.caption)
                                .foregroundColor(Color.theme.success)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text("Quantity")
                                .font(Typography.caption)
                                .foregroundColor(Color.theme.textSecondary)
                            
                            HStack(spacing: 12) {
                                Button(action: { if item.quantity > 1 { item.quantity -= 1 } }) {
                                    Image(systemName: "minus")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(item.quantity > 1 ? .primary : Color.theme.textDisabled)
                                
                                Text("\(item.quantity)")
                                    .font(Typography.body.monospacedDigit())
                                    .frame(minWidth: 20, alignment: .center)
                                
                                Button(action: { item.quantity += 1 }) {
                                    Image(systemName: "plus")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.theme.backgroundSecondary)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    requestedProducts.remove(atOffsets: indexSet)
                }
                
                Button(action: {
                    showingProductSelection = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle")
                        Text("Add Product")
                        Spacer()
                    }
                    .font(Typography.headline)
                    .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
            
            // Additional Information
            Section(header: Text("Additional Information").font(Typography.headline).foregroundColor(.primary)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reason")
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textSecondary)
                    
                    ZStack(alignment: .topLeading) {
                        if reason.isEmpty {
                            Text("Enter reason for this vendor request...")
                                .foregroundColor(Color.theme.textTertiary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $reason)
                            .frame(minHeight: 80)
                    }
                    
                    HStack {
                        Spacer()
                        Text("\(reason.count)/250")
                            .font(Typography.caption)
                            .foregroundColor(reason.count > 250 ? .red : Color.theme.textTertiary)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Request Summary
            Section(header: HStack {
                Image(systemName: "doc.text")
                Text("Request Summary")
            }.font(Typography.headline).foregroundColor(.primary)) {
                HStack {
                    VStack {
                        Text("Total Items")
                            .font(Typography.caption)
                            .foregroundColor(Color.theme.textSecondary)
                        Text("\(requestedProducts.count)")
                            .font(Typography.title3.bold())
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    VStack {
                        Text("Total Quantity")
                            .font(Typography.caption)
                            .foregroundColor(Color.theme.textSecondary)
                        Text("\(totalQuantity) Units")
                            .font(Typography.title3.bold())
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }
            
            // Submit Button
            Section {
                Button(action: {
                    submitRequests()
                }) {
                    HStack {
                        Image(systemName: "paperplane")
                        Text("Submit Vendor Request")
                    }
                    .font(Typography.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                }
                .listRowBackground(isFormValid ? Color.theme.accent : Color.theme.backgroundSecondary)
                .foregroundColor(isFormValid ? .white : Color.theme.textDisabled)
                .disabled(!isFormValid || reason.count > 250)
            }
        }
        .navigationTitle("Create Vendor Request")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingProductSelection) {
            NavigationStack {
                ProductSelectionView(products: viewModel.products) { selected in
                    if !requestedProducts.contains(where: { $0.product.sku == selected.sku }) {
                        requestedProducts.append(RequestedProduct(product: selected, quantity: 1))
                    }
                }
            }
        }
        .task {
            if viewModel.products.isEmpty {
                await viewModel.loadData()
            }
        }
        .onAppear {
            if let req = prefilledRequest {
                if let product = viewModel.products.first(where: { $0.sku == req.sku }) {
                    requestedProducts = [RequestedProduct(product: product, quantity: req.quantityRequested)]
                }
                reason = "Escalated from Store Request \(req.id)"
            }
        }
    }
    
    private func submitRequests() {
        let vendorName = viewModel.vendors.first(where: { $0.id == selectedVendorId })?.name ?? "Unknown"
        
        Task {
            for item in requestedProducts {
                await viewModel.submitVendorRequest(
                    sku: item.product.sku,
                    productName: item.product.name,
                    quantity: item.quantity,
                    vendorName: vendorName,
                    needByDate: needByDate,
                    reason: reason,
                    productId: item.product.id,
                    productImageURL: item.product.imageUrl
                )            }
            dismiss()
        }
    }
}

#Preview {
    let vm = ShipmentsViewModel()

    return NavigationStack {
        CreateVendorRequestView(prefilledRequest: nil)
            .environmentObject(vm)
    }
}
