import SwiftUI

struct RequestDetailView: View {
    let request: StoreRequest
    @ObservedObject var viewModel: RequestsViewModel
    
    @State private var isRejecting = false
    @State private var rejectReason = ""
    @Environment(\.dismiss) var dismiss

    private var currentRequest: StoreRequest {
        viewModel.request(withId: request.id) ?? request
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Header Info
                CardView {
                    VStack(alignment: .leading, spacing: Spacing.standard) {
                        HStack {
                            Text("Request Information")
                                .font(Typography.headline)
                            Spacer()
                            StatusBadge(status: currentRequest.status.displayName)
                        }
                        Divider()
                        DetailRow(title: "Product Name", value: currentRequest.productName)
                        DetailRow(title: "Store", value: currentRequest.storeName)
                        DetailRow(title: "Priority", value: currentRequest.priority.displayName)
                        DetailRow(title: "Created Date", value: currentRequest.createdAt.formatted(date: .abbreviated, time: .shortened))
                        
                        if let remark = currentRequest.managerRemark, !remark.isEmpty {
                            DetailRow(title: "Manager Remarks", value: remark)
                        }
                    }
                }
                
                // Product Info
                CardView {
                    VStack(alignment: .leading, spacing: Spacing.standard) {
                        Text("Product Information")
                            .font(Typography.headline)
                        Divider()
                        DetailRow(title: "SKU", value: currentRequest.sku)
                        DetailRow(title: "Product Name", value: currentRequest.productName)
                        DetailRow(title: "Requested Qty", value: "\(currentRequest.quantityRequested)")
                        DetailRow(title: "Available Warehouse Stock", value: "0") // Mock value for escalation scenario
                    }
                }
                
                // Actions
                if currentRequest.status == .pending {
                    VStack(spacing: Spacing.standard) {
                        PrimaryButton(title: "Approve", style: .primary) {

                            Task {
                                if await viewModel.approveRequest(currentRequest) {
                                    dismiss()
                                }
                            }

                        }
                        
                        PrimaryButton(title: "Reject", style: .secondary) {
                            isRejecting = true
                        }
                        
                        NavigationLink(value: AppDestination.createVendorRequest(prefilledRequest: currentRequest)) {
                            Text("Escalate To Vendor")
                                .font(Typography.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme.surface)
                                .foregroundColor(Color.theme.accent)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(Spacing.standard)
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.theme.background.ignoresSafeArea())
        .alert("Reject Request", isPresented: $isRejecting) {
            TextField("Reason", text: $rejectReason)
            Button("Cancel", role: .cancel) { }
            Button("Reject", role: .destructive) {

                Task {
                    if await viewModel.rejectRequest(currentRequest, reason: rejectReason) {
                        dismiss()
                    }
                }

            }
        }
        .alert(
            "Request Update Failed",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(Typography.subheadline)
                .foregroundColor(Color.theme.textSecondary)
            Spacer()
            Text(value)
                .font(Typography.body)
                .foregroundColor(Color.theme.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        RequestDetailView(
            request: StoreRequest(
                id: "REQ-001",
                requestType: .refill,
                storeName: "Flagship NYC",
                sku: "RLX-001",
                productName: "Rolex Daytona",
                quantityRequested: 2,
                priority: .urgent,
                managerRemark: "VIP Customer",
                status: .pending,
                createdAt: Date()
            ),
            viewModel: RequestsViewModel()
        )
    }
}
