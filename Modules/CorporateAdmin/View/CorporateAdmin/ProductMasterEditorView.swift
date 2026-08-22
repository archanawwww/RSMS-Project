import SwiftUI
import PhotosUI
import UIKit

struct ProductMasterEditorView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    let product: ProductMasterRecord?
    var preselectedCategory: String? = nil
    var onSave: (ProductMasterRecord) -> Void

    @State private var name: String
    @State private var sku: String
    @State private var category: String
    @State private var brand: String
    @State private var priceString: String
    @State private var costPriceString: String
    @State private var taxString: String
    @State private var barcode: String
    @State private var description: String
    @State private var isActive: Bool
    @State private var imageURL: String
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showImageSourceDialog = false
    @State private var showCamera = false
    @State private var showGallery = false

    @State private var statusMessage: String?
    @State private var isSuccess = false
    @State private var isSaving = false

    private let availableCategories = [
        "Purses", "Handbags", "Watches", "Fragrances", "Footwear",
        "Sneakers", "Jewelry", "Accessories", "Ready-to-Wear", "Leather Goods", "Other"
    ]

    init(
        product: ProductMasterRecord? = nil,
        preselectedCategory: String? = nil,
        onSave: @escaping (ProductMasterRecord) -> Void
    ) {
        self.product = product
        self.preselectedCategory = preselectedCategory
        self.onSave = onSave

        _name = State(initialValue: product?.name ?? "")
        _sku = State(initialValue: product?.sku ?? "")
        _category = State(initialValue: product?.category ?? preselectedCategory ?? "")
        _brand = State(initialValue: product?.brand ?? "")
        _priceString = State(initialValue: product != nil ? String(format: "%.0f", product!.price) : "")
        _costPriceString = State(initialValue: product != nil ? String(format: "%.0f", product!.costPrice) : "")
        _taxString = State(initialValue: product != nil ? String(format: "%.0f", product!.tax) : "18")
        _barcode = State(initialValue: product?.barcode ?? "")
        _description = State(initialValue: product?.description ?? "")
        _isActive = State(initialValue: product?.isActive ?? true)
        _imageURL = State(initialValue: product?.imageURL ?? "")
    }

    private var categoryOptions: [String] {
        var options = Set(availableCategories)
        options.formUnion(authManager.itemCategories.map(\.name))
        options.formUnion(authManager.productMasterRecords.map(\.category).filter { !$0.isEmpty })
        if !category.isEmpty { options.insert(category) }
        return options.sorted()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Core Identity") {
                    TextField("Product Name", text: $name)
                        .autocorrectionDisabled()

                    TextField("SKU Code", text: $sku)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    TextField("Brand", text: $brand)
                        .autocorrectionDisabled()

                    Picker("Category", selection: $category) {
                        Text("Select Category").tag("")
                        ForEach(categoryOptions, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)

                    if category.isEmpty {
                        Text("Choose a category so the product appears in catalog filters.")
                            .font(.caption)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                }

                Section("Financials & Pricing") {
                    HStack {
                        Text("Retail Price")
                        Spacer()
                        TextField("₹ Price", text: $priceString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .disabled(true)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }

                    HStack {
                        Text("Cost Price")
                        Spacer()
                        TextField("₹ Cost", text: $costPriceString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .disabled(true)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }

                    HStack {
                        Text("Tax Rate (%)")
                        Spacer()
                        TextField("Tax", text: $taxString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .disabled(true)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                }

                Section("Product Image") {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(12)
                    } else if !imageURL.isEmpty, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                    }

                    Button {
                        showImageSourceDialog = true
                    } label: {
                        Label("Upload Product Image", systemImage: "camera.fill")
                    }
                }

                Section("System Details") {
                    TextField("Barcode (EAN-13)", text: $barcode)
                        .keyboardType(.numberPad)

                    Toggle("Is Active (Sellable)", isOn: $isActive)
                        .tint(MatteTheme.Colors.primaryGold)
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Enter premium description...")
                                        .foregroundColor(Color(uiColor: .placeholderText))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }

                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundColor(isSuccess ? MatteTheme.Colors.success : MatteTheme.Colors.error)
                    }
                }
            }
            .navigationTitle(product == nil ? "New Product Master" : "Edit Product Master")
            .navigationBarTitleDisplayMode(.inline)
            .tint(MatteTheme.Colors.primaryGold)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(MatteTheme.Colors.espresso)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveChanges() }
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                        .fontWeight(.semibold)
                        .disabled(isSaving)
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $selectedImage)
            }
            .photosPicker(isPresented: $showGallery, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    guard let data = try? await newItem?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    selectedImage = image
                }
            }
            .confirmationDialog("Select Image Source", isPresented: $showImageSourceDialog) {
                Button("Camera") { showCamera = true }
                Button("Photo Library") { showGallery = true }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    private func saveChanges() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSku = sku.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            statusMessage = "Product Name cannot be empty."
            isSuccess = false
            return
        }

        guard !cleanSku.isEmpty else {
            statusMessage = "SKU Code cannot be empty."
            isSuccess = false
            return
        }

        guard !cleanBrand.isEmpty else {
            statusMessage = "Brand cannot be empty."
            isSuccess = false
            return
        }

        guard !cleanCategory.isEmpty else {
            statusMessage = "Please select a category."
            isSuccess = false
            return
        }

        let duplicateSKU = authManager.productMasterRecords.contains { existing in
            existing.sku.caseInsensitiveCompare(cleanSku) == .orderedSame && existing.id != product?.id
        }
        guard !duplicateSKU else {
            statusMessage = "A product with this SKU already exists."
            isSuccess = false
            return
        }

        isSaving = true

        Task {
            var resolvedImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
            if resolvedImageURL.isEmpty {
                resolvedImageURL = product?.imageURL ?? ""
            }

            if let selectedImage {
                do {
                    resolvedImageURL = try await SupabaseStorageService.shared.uploadProductImage(
                        image: selectedImage,
                        sku: cleanSku
                    )
                } catch {
                    await MainActor.run {
                        statusMessage = "Image upload failed: \(error.localizedDescription)"
                        isSuccess = false
                        isSaving = false
                    }
                    return
                }
            }

            let price = Double(priceString.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
            let costPrice = Double(costPriceString.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
            let tax = Double(taxString.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 18.0

            let productID = product?.id ?? UUID()
            let savedRecord = ProductMasterRecord(
                id: productID,
                name: cleanName,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                category: cleanCategory,
                sku: cleanSku,
                authenticitySettings: product?.authenticitySettings ?? AuthenticitySettings(requiresCertificate: false),
                createdAt: product?.createdAt ?? Date(),
                updatedAt: Date(),
                brand: cleanBrand,
                price: price,
                costPrice: costPrice,
                tax: tax,
                barcode: barcode.trimmingCharacters(in: .whitespacesAndNewlines),
                isActive: isActive,
                isArchived: product?.isArchived ?? false,
                imageURL: resolvedImageURL.isEmpty ? nil : resolvedImageURL
            )

            // Update or create pricing record
            if let existingPricing = authManager.pricingRules.first(where: { $0.productID == productID }) {
                let updatedPricing = SupabasePricing(
                    id: existingPricing.id,
                    productID: productID,
                    costPrice: costPrice,
                    basePrice: price,
                    tax: tax,
                    isActive: isActive,
                    createdAt: existingPricing.createdAt,
                    updatedAt: Date()
                )
                try? await SupabaseAuthService.shared.updatePricing(pricing: updatedPricing)
            } else {
                let newPricing = SupabasePricing(
                    id: UUID(),
                    productID: productID,
                    costPrice: costPrice,
                    basePrice: price,
                    tax: tax,
                    isActive: isActive,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try? await SupabaseAuthService.shared.createPricing(pricing: newPricing)
            }
            await authManager.fetchPricingRules()

            await MainActor.run {
                onSave(savedRecord)
                isSuccess = true
                statusMessage = "Product Master saved."
                isSaving = false
            }

            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run { dismiss() }
        }
    }
}
