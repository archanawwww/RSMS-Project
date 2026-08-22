import SwiftUI
import PhotosUI
import UIKit

struct ProductEditorView: View {
    @State private var name = ""
    @State private var sku = ""
    @State private var description = ""
    @State private var category = "Purses"
    @State private var requiresCertificate = false
    @State private var authNotes = ""
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showImageSourceDialog = false
    @State private var showCamera = false
    @State private var showGallery = false

    let productToEdit: ProductMasterRecord?
    let categories: [Category]
    var onSave: (ProductMasterRecord) -> Void
    var onCancel: () -> Void

    @State private var show2FA = false

    private var categoryOptions: [String] {
        var options = Set(categories.map(\.name))
        if !category.isEmpty { options.insert(category) }
        return options.sorted()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product Image") {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(12)
                    }

                    Button {
                        showImageSourceDialog = true
                    } label: {
                        Label("Upload Image", systemImage: "camera.fill")
                    }
                }

                Section(header: Text("Basic Info")) {
                    TextField("Product Name", text: $name)
                    TextField("SKU", text: $sku)
                    TextField("Description", text: $description)

                    Picker("Category", selection: $category) {
                        ForEach(categoryOptions, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Section(header: Text("Authenticity & Security")) {
                    Toggle("Certificate Required", isOn: $requiresCertificate)
                    if requiresCertificate {
                        TextField("Notes", text: $authNotes)
                    }
                }
            }
            .navigationTitle(productToEdit == nil ? "New Product" : "Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { show2FA = true }
                        .disabled(name.isEmpty || sku.isEmpty)
                }
            }
            .sheet(isPresented: $show2FA) {
                TwoFactorAuthView {
                    show2FA = false
                    Task { await saveProduct() }
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
            .onAppear {
                if let p = productToEdit {
                    name = p.name
                    sku = p.sku
                    description = p.description ?? ""
                    category = p.category.isEmpty ? "Purses" : p.category
                    requiresCertificate = p.authenticitySettings.requiresCertificate
                    authNotes = p.authenticitySettings.notes ?? ""
                }
            }
        }
    }

    private func saveProduct() async {
        let authSettings = AuthenticitySettings(
            requiresCertificate: requiresCertificate,
            notes: authNotes.isEmpty ? nil : authNotes
        )

        var imageURL = productToEdit?.imageURL
        if let selectedImage {
            imageURL = try? await SupabaseStorageService.shared.uploadProductImage(
                image: selectedImage,
                sku: sku
            )
        }

        let newProduct = ProductMasterRecord(
            id: productToEdit?.id ?? UUID(),
            name: name,
            description: description.isEmpty ? nil : description,
            category: category,
            sku: sku,
            authenticitySettings: authSettings,
            createdAt: productToEdit?.createdAt ?? Date(),
            updatedAt: Date(),
            imageURL: imageURL
        )

        await MainActor.run {
            onSave(newProduct)
        }
    }
}
