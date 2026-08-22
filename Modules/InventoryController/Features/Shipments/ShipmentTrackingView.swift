import SwiftUI

struct ShipmentTrackingView: View {
    let initialShipment: Shipment
    @EnvironmentObject var viewModel: ShipmentsViewModel
    
    var shipment: Shipment {
        viewModel.shipments.first(where: { $0.id == initialShipment.id }) ?? initialShipment
    }
    
    
    @State private var showingActionAlert = false
    @State private var activeAlertMessage = ""
    @State private var showASNAlert = false
    
    var body: some View {
        List {
            if viewModel.shipmentsWithVariance.contains(shipment.id) {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(Color(hex: "#F59E0B"))
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Variance Detected")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.theme.textPrimary)
                            Text("Discrepancies require review.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        
                        Spacer()
                        
                        Button("View Report") {
                            // Mock navigation to report
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.theme.accent)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // 1. SHIPMENT HEADER
            Section {
                ShipmentHeaderCompactCard(shipment: shipment)
            }
            
            // 2. SHIPMENT TIMELINE
            Section {
                ShipmentTimelineClean(status: shipment.status, shipment: shipment)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            
            // 3. SHIPMENT STATUS MESSAGE
            ShipmentStatusRow(
                shipment: shipment
            )
            
            // 4. ACTIONS or RESULTS
//            if shipment.status == .completed {
//                Section(header: Text("Receiving Results")) {
//                    Button(action: {
//                        activeAlertMessage = "Opening Variance Report..."
//                        showingActionAlert = true
//                    }) {
//                        HStack {
//                            SettingsRow(icon: "doc.text.magnifyingglass", title: "View Variance Report")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 14, weight: .semibold))
//                                .foregroundColor(Color(UIColor.tertiaryLabel))
//                        }
//                    }
//                    Button(action: {
//                        activeAlertMessage = "Opening Audit Trail..."
//                        showingActionAlert = true
//                    }) {
//                        HStack {
//                            SettingsRow(icon: "list.clipboard", title: "View Audit Trail")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 14, weight: .semibold))
//                                .foregroundColor(Color(UIColor.tertiaryLabel))
//                        }
//                    }
//                }
//            }
            if shipment.status == .completed {

                Section(header: Text("Receiving Results")) {
                    
                    Button(action: {
                        activeAlertMessage = "Opening Audit Trail..."
                        showingActionAlert = true
                    }) {

                        HStack {

                            SettingsRow(
                                icon: "list.clipboard",
                                title: "View Audit Trail"
                            )

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }


                    NavigationLink(value: AppDestination.asnDetails(shipment.id)) {

                        SettingsRow(
                            icon: "doc.text",
                            title: "View ASN"
                        )
                    }

                    Button(action: {
                        if let url = URL(string: "tel:+919354801676") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                activeAlertMessage = "Calling +91 93548 01676... (Simulated)"
                                showingActionAlert = true
                            }
                        }
                    }) {

                        HStack {

                            SettingsRow(
                                icon: "phone",
                                title: "Contact Vendor"
                            )

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }

                }
            }
            else {

                Section {

                    if shipment.status == .created {

                        Button {

                            showASNAlert = true

                        } label: {

                            HStack {

                                SettingsRow(
                                    icon: "doc.text",
                                    title: "View ASN"
                                )

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                            }
                        }

                    } else {

                        NavigationLink(value: AppDestination.asnDetails(shipment.id)) {

                            SettingsRow(
                                icon: "doc.text",
                                title: "View ASN"
                            )
                        }

                    }

                    Button(action: {

                        if let url = URL(string: "tel:+919354801676") {

                            if UIApplication.shared.canOpenURL(url) {

                                UIApplication.shared.open(url)

                            } else {

                                activeAlertMessage = "Calling +91 93548 01676 (Simulated)"
                                showingActionAlert = true
                            }
                        }

                    }) {

                        HStack {

                            SettingsRow(
                                icon: "phone",
                                title: "Contact Vendor"
                            )

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }

                }

            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "#FDFBF8").ignoresSafeArea())
        .navigationTitle("Shipment Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Not Received", isPresented: $showASNAlert) {

            Button("OK", role: .cancel) { }

        } message: {

            Text("ASN will be available once the shipment is dispatched.")
        }
        .alert("Coming Soon", isPresented: $showingActionAlert, presenting: activeAlertMessage) { _ in
            Button("OK", role: .cancel) { }
        } message: { message in
            Text(message)
        }
    }
}

// MARK: - Sections

struct ShipmentHeaderCompactCard: View {
    let shipment: Shipment
    
    var etaText: String {

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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shipment.id)
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundColor(Color.theme.textPrimary)
                    Text(shipment.vendorName)
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(Color.theme.textSecondary)
                }
                Spacer()
                StatusChip(status: shipment.status)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ETA")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.theme.textSecondary)
                    Text(etaText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.theme.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ASN")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.theme.textSecondary)
                    Text(

                        shipment.status == .completed

                        ? "Matched"

                        : (shipment.asnNumber ?? "Pending")

                    )
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.theme.textPrimary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
}

//struct ShipmentTimelineClean: View {
//    let status: ShipmentStatus
//    let shipment: Shipment
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            ShipmentTimelineNode(
//                title: "Dispatched",
//                icon: "box.truck",
//                date: shipment.expectedDate.addingTimeInterval(-86400 * 2), // Mock
//                state: status != .created && status != .approved ? .completed : (status == .created || status == .approved ? .current : .future)
//            )
//            
//            ShipmentTimelineConnector(isActive: status != .created && status != .approved)
//            
//            ShipmentTimelineNode(
//                title: "In Transit",
//                icon: "shippingbox",
//                date: shipment.expectedDate.addingTimeInterval(-86400),
//                state: status == .inTransit ? .current : (status == .awaitingReceipt || status == .processing || status == .completed || status == .received || status == .exception ? .completed : .future)
//            )
//            
//            ShipmentTimelineConnector(isActive: status == .awaitingReceipt || status == .processing || status == .completed || status == .received || status == .exception)
//            
//            ShipmentTimelineNode(
//                title: "Arrived",
//                icon: "building.2",
//                date: (status == .completed || status == .received) ? (shipment.completedDate ?? shipment.expectedDate) : ((status == .awaitingReceipt || status == .processing || status == .exception) ? shipment.expectedDate : nil),
//                state: (status == .completed || status == .received) ? .completed : ((status == .awaitingReceipt || status == .processing || status == .exception) ? .current : .future)
//            )
//        }
//        .padding(.vertical, 16)
//    }
//}

struct ShipmentTimelineClean: View {
    let status: ShipmentStatus
    let shipment: Shipment

    var body: some View {
        HStack(spacing: 0) {

            // DISPATCHED
            ShipmentTimelineNode(
                title: "Dispatched",
                icon: "box.truck",
                date: shipment.dispatchedAt,
                state:
                    status == .created
                    ? .future
                    : status == .dispatched
                        ? .current
                        : .completed
            )

            ShipmentTimelineConnector(
                isActive:
                    status == .inTransit ||
                    status == .awaitingReceipt ||
                    status == .processing ||
                    status == .completed ||
                    status == .received ||
                    status == .exception
            )

            // IN TRANSIT
            ShipmentTimelineNode(
                title: "In Transit",
                icon: "shippingbox",
                date: shipment.inTransitAt,
                state:
                    status == .inTransit
                    ? .current
                    : (
                        status == .awaitingReceipt ||
                        status == .processing ||
                        status == .completed ||
                        status == .received ||
                        status == .exception
                    )
                    ? .completed
                    : .future
            )

            ShipmentTimelineConnector(
                isActive:
                    status == .awaitingReceipt ||
                    status == .processing ||
                    status == .completed ||
                    status == .received ||
                    status == .exception
            )

            // ARRIVED
            ShipmentTimelineNode(
                title: "Arrived",
                icon: "building.2",
                date:
                    (status == .completed || status == .received)
                    ? (shipment.receivedAt ?? shipment.arrivedAt ?? shipment.expectedDate)
                    : (
                        status == .awaitingReceipt ||
                        status == .processing ||
                        status == .exception
                    )
                    ? (shipment.arrivedAt ?? shipment.expectedDate)
                    : nil,
                state:
                    (
                        status == .awaitingReceipt ||
                        status == .processing ||
                        status == .exception
                    )
                    ? .current
                    : (
                        status == .completed ||
                        status == .received
                    )
                    ? .completed
                    : .future
            )
        }
        .padding(.vertical, 16)
    }
}

struct ShipmentStatusRow: View {
    let shipment: Shipment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Color.theme.accent)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(getMessage())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(
                        shipment.arrivedAt == nil
                        ? "Expected warehouse arrival"
                        : (
                            shipment.status == .completed
                            ? "Delivery Received at"
                            : "Delivery Arrived at"
                        )
                    )
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.theme.textSecondary)
                    Text(displayDate)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.theme.textPrimary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    func getMessage() -> String {
        
        switch shipment.status {
            
        case .created:
            return "Shipment has been created."
            
        case .dispatched:
            return "Shipment has been dispatched."
            
        case .inTransit:
            return "Shipment is currently in transit."
            
        case .awaitingReceipt:
            return "Shipment has arrived at the warehouse."
            
        case .processing:
            return "Shipment is being processed."
            
        case .exception:
            return "Shipment has encountered an exception."
            
        case .completed,
                .received:
            return "Shipment has been received."
            
        case .approved:
            return "Shipment has been approved."
            
        case .returned:
            return "Shipment has been returned."
            
        case .cancelled:
            return "Shipment has been cancelled."
        }
    }
    
    var displayDate: String {

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
             .exception:

            return (
                shipment.arrivedAt
                ?? shipment.expectedDate
            )
            .formatted(
                date: .abbreviated,
                time: .shortened
            )

        case .completed,
             .received:

            return (
                shipment.receivedAt
                ?? shipment.arrivedAt
                ?? shipment.expectedDate
            )
            .formatted(
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
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var iconColor: Color = Color.theme.accent
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.theme.textPrimary)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Timeline Helpers

enum ShipmentTimelineState {
    case completed
    case current
    case future
}

struct ShipmentTimelineNode: View {
    let title: String
    let icon: String
    let date: Date?
    let state: ShipmentTimelineState
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if state == .completed {
                    Circle()
                        .fill(Color.theme.accent)
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else if state == .current {
                    Circle()
                        .fill(Color.theme.accent.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Circle()
                        .stroke(Color.theme.accent, lineWidth: 2)
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.theme.accent)
                } else {
                    Circle()
                        .stroke(Color(UIColor.tertiaryLabel), lineWidth: 2)
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: state == .future ? .regular : .semibold))
                    .foregroundColor(state == .future ? Color(UIColor.secondaryLabel) : Color.theme.textPrimary)
                    .fixedSize(horizontal: true, vertical: false)
                
                if (state == .completed || state == .current), let d = date {
                    Text(d.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .fixedSize(horizontal: true, vertical: false)
                } else {
                    Text("Pending")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ShipmentTimelineConnector: View {
    let isActive: Bool
    var body: some View {
        Rectangle()
            .fill(isActive ? Color.theme.accent : Color(UIColor.tertiaryLabel))
            .frame(height: 2)
            .padding(.bottom, 36) // Align with circle center
    }
}

#Preview {
    NavigationStack {
        ShipmentTrackingView(initialShipment: Shipment(
            id: "SHP-123",
            vendorRequestID: "REQ-123",
            vendorName: "Acme",
            status: .inTransit,
            expectedDate: Date(),
            origin: "NYC",
            destination: "LA",
            itemsCount: 10,
            asnNumber: "ASN-123",
            carrier: "FedEx",
            trackingNumber: "TRK-123"
        ))
    }
}
