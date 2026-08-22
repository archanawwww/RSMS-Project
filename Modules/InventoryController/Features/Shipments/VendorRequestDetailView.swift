import SwiftUI

struct VendorRequestDetailView: View {
    let request: VendorRequest
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                CardView {
                    VStack(alignment: .leading, spacing: Spacing.standard) {
                        HStack {
                            Text("Request Information")
                                .font(Typography.headline)
                            Spacer()
                            StatusBadge(status: request.status.title)
                        }
                        Divider()
                        DetailRow(title: "Request ID", value: request.id)
                        DetailRow(title: "Vendor", value: request.vendorName)
                        DetailRow(title: "SKU", value: request.sku)
                        DetailRow(title: "Product Name", value: request.productName)
                        DetailRow(title: "Quantity", value: "\(request.quantity)")
                        DetailRow(title: "Need By", value: request.needByDate.formatted(date: .abbreviated, time: .omitted))
                        DetailRow(title: "Created On", value: request.createdAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                
                CardView {
                    VStack(alignment: .leading, spacing: Spacing.standard) {
                        Text("Timeline")
                            .font(Typography.headline)
                        Divider()
                        
                        TimelineView(status: request.status)
                    }
                }
                
                if request.status == .dispatched {
                    NavigationLink(value: AppDestination.shipmentTracking(Shipment(id: "SH-\(request.id)", vendorRequestID: request.id, vendorName: request.vendorName, status: .dispatched, expectedDate: Date().addingTimeInterval(86400 * 2)))) {
                        Text("Track Shipment")
                            .font(Typography.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(Spacing.standard)
        }
        .navigationTitle(request.id)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.theme.background.ignoresSafeArea())
    }
}

struct TimelineView: View {
    let status: ShipmentStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TimelineNode(title: "Request Created", isCompleted: true, isLast: false)
            TimelineNode(title: "Approved", isCompleted: status != .created, isLast: false)
            TimelineNode(title: "Dispatched", isCompleted: status == .dispatched || status == .inTransit || status == .received, isLast: false)
            TimelineNode(title: "Received", isCompleted: status == .received, isLast: true)
        }
    }
}

struct TimelineNode: View {
    let title: String
    let isCompleted: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.standard) {
            VStack {
                Circle()
                    .fill(isCompleted ? Color.theme.approved : Color.theme.surface)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle().stroke(Color.theme.textTertiary, lineWidth: isCompleted ? 0 : 2)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.theme.approved : Color.theme.surface)
                        .frame(width: 2, height: 30)
                }
            }
            
            Text(title)
                .font(Typography.body)
                .foregroundColor(isCompleted ? Color.theme.textPrimary : Color.theme.textSecondary)
                .padding(.top, -2)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        VendorRequestDetailView(request: VendorRequest(
            id: "REQ-123",
            vendorName: "Acme",
            sku: "SKU-123",
            productName: "Test Product",
            quantity: 10,
            status: .created,
            needByDate: Date(),
            createdAt: Date(),
            sourceRequestId: nil
        ))
    }
}


