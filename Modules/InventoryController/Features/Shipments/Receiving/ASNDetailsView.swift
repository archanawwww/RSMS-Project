import SwiftUI

struct ASNDetailsView: View {
    let shipmentId: String
    
    @StateObject private var viewModel = ASNViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var shipmentsViewModel: ShipmentsViewModel
    
    var canStartReceiving: Bool {
        guard let shipment = shipmentsViewModel.shipments.first(where: { $0.id == shipmentId }) else { return false }
        // "Arrived" states in this domain typically include awaitingReceipt, processing, exception
        return shipment.status == .awaitingReceipt
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#FDFBF8").ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading ASN Details...")
            } else if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .font(.headline)
                        .foregroundColor(Color.theme.textPrimary)
                    Button("Retry") {
                        Task { await viewModel.loadASN(shipmentId: shipmentId) }
                    }
                    .padding(.top)
                }
            } else if let asn = viewModel.asn {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Card
                            ASNHeaderCard(
                                asn: asn,
                                shipment: shipmentsViewModel.shipments.first {
                                    $0.id == shipmentId
                                }
                            )
                            // Metrics
                            ReceivingProgressView(asn: asn)
                        }
                        .padding(16)
                        .padding(.bottom, 24) // Space for sticky button
                    }
                }
                
                //Sticky Bottom Button
                if canStartReceiving {
                    VStack {
                        Spacer()
                        NavigationLink(value: AppDestination.qrScanner(asn)) {
                            Text("Start Receiving")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .background(.bar)
                    }
                }
            }
        }
        .navigationTitle("ASN Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadASN(shipmentId: shipmentId)
        }
    }
}

// MARK: - Subviews

struct ASNHeaderCard: View {
                    
                    let asn: ASN
                    let shipment: Shipment?

    var primaryItem: ASNItem? {
        asn.items.first
    }
    
    var etaText: String {

        guard let shipment = shipment else {
            return "NA"
        }

        switch shipment.status {

        case .created:

            return "NA"

        case .dispatched:

            if let dispatched = shipment.dispatchedAt {

                return dispatched
                    .addingTimeInterval(60)
                    .formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
            }

            return "NA"

        case .inTransit:

            if let transit = shipment.inTransitAt {

                return transit
                    .addingTimeInterval(30)
                    .formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
            }

            return "NA"

        case .awaitingReceipt,
             .processing,
             .exception,
             .completed,
             .received:

            if let transit = shipment.inTransitAt {

                return transit
                    .addingTimeInterval(30)
                    .formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
            }

            return shipment.expectedDate.formatted(
                date: .abbreviated,
                time: .shortened
            )

        default:

            return shipment.expectedDate.formatted(
                date: .abbreviated,
                time: .shortened
            )
        }
    }
                    
                    var body: some View {
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .leading, spacing: 18) {
                                HStack(alignment: .top, spacing: 14) {
                                    ProductImageView(imageURL: primaryItem?.productImageURL)
                                        .frame(width: 72, height: 72)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(primaryItem?.productName ?? "Product")
                                            .font(.system(.title3, design: .default).weight(.bold))
                                            .foregroundColor(Color.theme.textPrimary)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Text("SKU: \(primaryItem?.sku ?? "NA")")
                                            .font(.system(.subheadline, design: .default).weight(.regular))
                                            .foregroundColor(Color.theme.textSecondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.82)
                                        
                                        Text("Expected Quantity: \(primaryItem?.expectedQuantity ?? asn.totalExpected)")
                                            .font(.system(.subheadline, design: .default).weight(.semibold))
                                            .foregroundColor(Color.theme.textPrimary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.82)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Divider()
                                    .background(Color.theme.border)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ASNDetailInfoRow(
                                        icon: "number",
                                        title: "Request ID",
                                        value: asn.id.uuidString
                                    )
                                    
                                    ASNDetailInfoRow(
                                        icon: "person.text.rectangle",
                                        title: "Shipment ID",
                                        value: asn.shipmentId
                                    )
                                    
                                    ASNDetailInfoRow(
                                        icon: "calendar",
                                        title: "ETA",
                                        value: etaText
                                    )
                                    
                                    ASNDetailInfoRow(
                                        icon: "building.2",
                                        title: "Vendor Name",
                                        value: asn.vendorName
                                    )
                                }
                            }
                            
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 2)
                    }
                }

                struct ProductImageView: View {
                    let imageURL: String?

                    var body: some View {
                        AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()

                            default:
                                ZStack {
                                    Color(UIColor.systemGray6)

                                    Image(systemName: "shippingbox")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                    }
                }

                struct ASNDetailInfoRow: View {
                    let icon: String
                    let title: String
                    let value: String

                    var body: some View {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: icon)
                                .foregroundColor(Color.theme.textSecondary)
                                .font(.system(size: 16))
                                .frame(width: 20)

                            Text(title)
                                .font(.system(.subheadline, design: .default).weight(.regular))
                                .foregroundColor(Color.theme.textSecondary)

                            Spacer(minLength: 12)

                            Text(value)
                                .font(.system(.subheadline, design: .default).weight(.regular))
                                .foregroundColor(Color.theme.textPrimary)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                        }
                    }
                }
                
                struct ReceivingProgressView: View {
                    let asn: ASN
                    
                    var progress: Double {
                        guard asn.totalExpected > 0 else { return 0 }
                        return Double(asn.totalReceived) / Double(asn.totalExpected)
                    }
                    
                    var body: some View {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Receiving Progress")
                                .font(.system(.headline, design: .default).weight(.medium))
                                .foregroundColor(Color.theme.textPrimary)
                            
                            VStack(spacing: 24) {
                                // Progress Bar
                                HStack(spacing: 12) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color(UIColor.systemGray5))
                                                .frame(height: 8)
                                            
                                            Capsule()
                                                .fill(Color.theme.accent)
                                                .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1.0)), height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                    
                                    Text("\(Int(progress * 100))%")
                                        .font(.system(.subheadline, design: .default).weight(.medium))
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                
                                // Metrics
                                HStack {
                                    VStack(spacing: 4) {
                                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                                            Text("\(asn.totalReceived)")
                                                .font(.system(.title3, design: .default).weight(.semibold))
                                                .foregroundColor(Color.theme.textPrimary)
                                            Text("/ \(asn.totalExpected)")
                                                .font(.system(.headline, design: .default).weight(.regular))
                                                .foregroundColor(Color.theme.textPrimary)
                                        }
                                        Text("Items Received")
                                            .font(.system(.caption, design: .default).weight(.regular))
                                            .foregroundColor(Color.theme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Divider()
                                        .frame(height: 40)
                                        .background(Color.theme.border)
                                    
                                    VStack(spacing: 4) {
                                        Text("\(max(0, asn.totalExpected - asn.totalReceived))")
                                            .font(.system(.title3, design: .default).weight(.semibold))
                                            .foregroundColor(Color.theme.textPrimary)
                                        Text("Items Remaining")
                                            .font(.system(.caption, design: .default).weight(.regular))
                                            .foregroundColor(Color.theme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 2)
                        }
                    }
                }
                
                //struct ASNItemRow: View {
                //    let item: ASNItem
                //
                //    var receivingStatus: String {
                //        if item.receivedQuantity == 0 {
                //            return "Not Started"
                //        } else if item.receivedQuantity < item.expectedQuantity {
                //            return "Partially Received"
                //        } else {
                //            return "Completed"
                //        }
                //    }
                //
                //    var statusColor: Color {
                //        if item.receivedQuantity >= item.expectedQuantity {
                //            return Color.theme.textSecondary // Muted gray for completed
                //        } else {
                //            return Color.theme.accent // Gold for Not Started / Partially Received
                //        }
                //    }
                //
                //    var body: some View {
                //        HStack(alignment: .center, spacing: 16) {
                //            // Placeholder Image
                //            ZStack {
                //                RoundedRectangle(cornerRadius: 12)
                //                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                //                Image(systemName: "shippingbox")
                //                    .font(.system(size: 24))
                //                    .foregroundColor(Color.theme.textSecondary)
                //            }
                //            .frame(width: 60, height: 60)
                //
                //            VStack(alignment: .leading, spacing: 8) {
                //                HStack(alignment: .top) {
                //                    VStack(alignment: .leading, spacing: 2) {
                //                        Text(item.productName)
                //                            .font(.system(.subheadline, design: .default).weight(.semibold))
                //                            .foregroundColor(Color.theme.textPrimary)
                //
                //                        Text("SKU: \(item.sku)")
                //                            .font(.system(.caption, design: .default).weight(.regular))
                //                            .foregroundColor(Color.theme.textSecondary)
                //                    }
                //                    Spacer()
                //
                //                    // Status Pill
                //                    HStack(spacing: 4) {
                //                        Circle()
                //                            .strokeBorder(statusColor, lineWidth: 1.5)
                //                            .frame(width: 10, height: 10)
                //
                //                        Text(receivingStatus)
                //                            .font(.system(.caption, design: .default).weight(.medium))
                //                            .foregroundColor(statusColor)
                //                    }
                //                    .padding(.horizontal, 8)
                //                    .padding(.vertical, 4)
                //                    .background(statusColor.opacity(0.1))
                //                    .cornerRadius(8)
                //                }
                //
                //                HStack(spacing: 12) {
                //                    Text("Expected ")
                //                        .font(.system(.caption, design: .default).weight(.regular))
                //                        .foregroundColor(Color.theme.textSecondary)
                //                    + Text("\(item.expectedQuantity)")
                //                        .font(.system(.caption, design: .default).weight(.semibold))
                //                        .foregroundColor(Color.theme.textPrimary)
                //
                //                    Text("|")
                //                        .font(.system(.caption, design: .default).weight(.regular))
                //                        .foregroundColor(Color.theme.textTertiary)
                //
                //                    Text("Received ")
                //                        .font(.system(.caption, design: .default).weight(.regular))
                //                        .foregroundColor(Color.theme.textSecondary)
                //                    + Text("\(item.receivedQuantity)")
                //                        .font(.system(.caption, design: .default).weight(.semibold))
                //                        .foregroundColor(Color.theme.textPrimary)
                //                }
                //            }
                //        }
                //        .padding(16)
                //        .background(Color.white)
                //        .cornerRadius(16)
                //        .overlay(
                //            RoundedRectangle(cornerRadius: 16)
                //                .stroke(Color.theme.border, lineWidth: 1)
                //        )
                //    }
                
                struct ASNItemRow: View {
                    let item: ASNItem
                    
                    var body: some View {
                        HStack(spacing: 16) {
                            
                            // Product Image
                            AsyncImage(url: URL(string: item.productImageURL ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                    
                                default:
                                    ZStack {
                                        Color(UIColor.systemGray6)
                                        
                                        Image(systemName: "shippingbox")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                            
                            VStack(alignment: .leading, spacing: 6) {
                                
                                Text(item.productName)
                                    .font(.system(size: 19, weight: .semibold))
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Text("SKU: \(item.sku)")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                Text("Expected Quantity: \(item.expectedQuantity)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.theme.border, lineWidth: 1)
                        )
                    }
                }
                
#Preview {
    NavigationStack {
        ASNDetailsView(shipmentId: "SHP-250528-002")
            .environmentObject(ShipmentsViewModel())
    }
}
