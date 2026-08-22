import SwiftUI
import AVFoundation

struct CycleCountExecutionView: View {
    let session: CycleCountSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var items: [CycleCountItem] = []
    @State private var isLoadingItems = true
    
    @State private var lastScannedSKU: String?
    @State private var scannedProduct: CycleCountItem?
    
    @State private var showCountProgress = false
    @State private var verifyItem: CycleCountItem?
    
    private let productRepository = ProductRepository()
    
    private var totalCount: Int { items.count }
    private var countedCount: Int { items.filter { !$0.state.isNotCounted }.count }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            if isLoadingItems {
                ProgressView()
            } else {
                scannerContent
            }
        }
        .navigationTitle("Scan Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Toggle Flash
                } label: {
                    Image(systemName: "bolt")
                        .foregroundColor(Color.theme.brand)
                }
            }
        }
        .task {
            await loadItems()
        }
        // Navigation to Verification
        .navigationDestination(item: $verifyItem) { item in
            ProductCountingView(item: item) { newState in
                if let idx = items.firstIndex(where: { $0.id == item.id }) {
                    items[idx].state = newState
                    CycleCountStore.shared.saveItemState(sessionID: session.id, sku: items[idx].sku, state: newState)
                    
                    // Re-calculate variances
                    let variances = items.filter { $0.state.isVariance }.count
                    let counted = items.filter { !$0.state.isNotCounted }.count
                    CycleCountStore.shared.updateSessionProgress(id: session.id, counted: counted, total: totalCount, variances: variances)
                }
                verifyItem = nil
            }
        }
        // Navigation to Progress List
        .navigationDestination(isPresented: $showCountProgress) {
            CycleCountProgressView(session: session, items: $items)
        }
    }
    
    @StateObject private var scannerVM = BarcodeScannerModel()
    
    private var scannerContent: some View {
        VStack(spacing: 0) {
            Text("Scan item barcode or QR code")
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textSecondary)
                .padding(.vertical, 16)
            
            // Scanner View
            ZStack {
                CameraPreviewView(session: scannerVM.session)
                    .onAppear {
                        scannerVM.onNewSerial = { sku in
                            handleScan(sku: sku)
                        }
                        scannerVM.configureAndStart()
                    }
                    .onDisappear {
                        scannerVM.stopRunning()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Overlay brackets
                Image(systemName: "viewfinder")
                    .font(.system(size: 200, weight: .ultraLight))
                    .foregroundColor(Color.theme.brand)
            }
            .frame(maxHeight: 350)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Scanned Preview
            if let product = scannedProduct {
                scannedProductPreview(product)
            }
            
            // Progress Bar
            Button {
                showCountProgress = true
            } label: {
                progressView
            }
            .buttonStyle(.plain)
            .padding(16)
        }
    }
    
    private func scannedProductPreview(_ product: CycleCountItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Item")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.theme.textSecondary)
                .textCase(.uppercase)
            
            HStack(spacing: 12) {
                InventoryProductThumbnail(imageUrl: product.imageUrl, category: product.category, size: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    Text(product.sku)
                        .font(.system(size: 14))
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("System Qty")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textSecondary)
                    Text("\(product.expectedQuantity)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.theme.textPrimary)
                }
            }
        }
        .padding(16)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
        .padding(.horizontal, 16)
    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Count Progress")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.theme.textSecondary)
            
            HStack {
                Text("\(countedCount) of \(totalCount) items counted")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.textPrimary)
                Spacer()
                let pct = totalCount > 0 ? Int((Double(countedCount) / Double(totalCount)) * 100) : 0
                Text("\(pct)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.theme.brand)
            }
        }
        .padding(16)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.theme.border, lineWidth: 1))
    }
    
    private func handleScan(sku: String) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        if let item = items.first(where: { $0.sku == sku }) {
            scannedProduct = item
            verifyItem = item
        } else {
            // Not found handling
        }
    }
    
    private func loadItems() async {
        guard !session.productIDs.isEmpty else {
            isLoadingItems = false
            return
        }
        do {
            let allProducts = try await productRepository.fetchProducts()
            let selected = allProducts.filter { session.productIDs.contains($0.id.uuidString) }
            items = selected.map { product in
                CycleCountItem(
                    name: product.name,
                    sku: product.sku,
                    imageUrl: product.imageUrl,
                    category: product.category,
                    basePrice: product.basePrice,
                    state: .notCounted(expected: max(product.currentStock ?? 0, 0))
                )
            }

            let savedStates = CycleCountStore.shared.savedStates(for: session.id)
            if !savedStates.isEmpty {
                for i in items.indices {
                    if let saved = savedStates[items[i].sku] {
                        items[i].state = saved
                    }
                }
            }
        } catch {
            items = []
        }
        isLoadingItems = false
    }
}


