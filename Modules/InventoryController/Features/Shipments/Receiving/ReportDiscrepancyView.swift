import SwiftUI
import PhotosUI

struct ReportDiscrepancyView: View {
    let session: ReceivingSession
    @Environment(\.dismiss) private var dismiss
    
    // Default reason to Over Shipment if variance is positive, else Short Shipment
    @State private var selectedReason: DiscrepancyReason = .overShipment
    @State private var notes: String = ""
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    @State private var showConfirmation = false
    @State private var navigateToProcessing = false
    
    var discrepantItems: [ASNItem] {
        session.asn.items.filter { $0.expectedQuantity != $0.receivedQuantity }
    }
    
    var body: some View {
        Form {
            Section("Shipment") {
                LabeledContent("ASN", value: session.asn.id.uuidString)
                LabeledContent("Warehouse", value: "WH-01 Central Warehouse")
                LabeledContent("Vendor", value: session.asn.vendorName)
            }
            
            Section("Affected Products (\(discrepantItems.count))") {
                ForEach(discrepantItems) { item in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "shippingbox.fill")
                                .font(.title)
                                .foregroundColor(Color(hex: "#B9823A"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.productName)
                                    .font(.headline)
                                Text("SKU: \(item.sku)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .center) {
                                Text("Expected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(item.expectedQuantity)")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .center) {
                                Text("Received")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(item.receivedQuantity)")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .center) {
                                Text("Variance")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                let variance = item.receivedQuantity - item.expectedQuantity
                                Text("\(variance > 0 ? "+" : "")\(variance)")
                                    .font(.headline)
                                    .foregroundColor(variance == 0 ? .primary : Color(hex: "#B9823A"))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section("Reason for Discrepancy") {
                List {
                    ForEach(DiscrepancyReason.allCases) { reason in
                        Button {
                            selectedReason = reason
                        } label: {
                            HStack {
                                Text(reason.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "#B9823A"))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                }
                            }
                        }
                    }
                }
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
                    .overlay(
                        Text(notes.isEmpty ? "Provide details about the discrepancy..." : "")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                        , alignment: .topLeading
                    )
            }
            
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        if selectedImages.count < 5 {
                            PhotosPicker(
                                selection: $selectedItems,
                                maxSelectionCount: 5 - selectedImages.count,
                                matching: .images
                            ) {
                                VStack {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                    Text("Add Photos")
                                        .font(.caption)
                                }
                                .foregroundColor(Color(hex: "#B9823A"))
                                .frame(width: 80, height: 80)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                        .foregroundColor(Color(hex: "#B9823A"))
                                )
                            }
                            .onChange(of: selectedItems) { oldItems, newItems in
                                Task {
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            selectedImages.append(uiImage)
                                        }
                                    }
                                    selectedItems.removeAll()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Evidence (Photos) (\(selectedImages.count)/5)")
            }
        }
        .navigationTitle("Report Discrepancy")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                showConfirmation = true
            } label: {
                Text("Submit Report")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#B9823A"))
            .controlSize(.large)
            .padding()
            .background(.bar)
        }
        .confirmationDialog(
            "Submit Discrepancy Report?",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Submit", role: .none) {
                navigateToProcessing = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will log the discrepancy and notify the manager for review.")
        }
        .navigationDestination(isPresented: $navigateToProcessing) {
            DiscrepancyProcessingView(session: session)
        }
        .onAppear {
            if let firstVariance = discrepantItems.first {
                if firstVariance.receivedQuantity > firstVariance.expectedQuantity {
                    selectedReason = .overShipment
                } else {
                    selectedReason = .shortShipment
                }
            }
        }
    }
}

#Preview {
    let mockASN = ASN(
        id: UUID(),
        shipmentId: "SHP-992",
        vendorName: "Boutique - New York",
        expectedDate: Date(),
        status: "Pending",
        totalExpected: 15,
        totalReceived: 13,
        createdAt: Date(),
        items: [
            ASNItem(id: UUID(), asnId: "ASN-10293", productId: nil, sku: "SKU-123", productName: "Luxury Handbag", productImageURL: nil, expectedQuantity: 5, receivedQuantity: 3),
            ASNItem(id: UUID(), asnId: "ASN-10293", productId: nil, sku: "SKU-456", productName: "Silk Scarf", productImageURL: nil, expectedQuantity: 10, receivedQuantity: 10)
        ]
    )
    
    NavigationStack {
        ReportDiscrepancyView(session: ReceivingSession(asn: mockASN))
    }
}
