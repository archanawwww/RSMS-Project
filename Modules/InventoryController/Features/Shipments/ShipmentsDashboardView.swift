import SwiftUI

struct ShipmentsDashboardView: View {
    @EnvironmentObject private var viewModel: ShipmentsViewModel
    @State private var showingFilterSheet = false
    @State private var resetID = UUID()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sticky Sub-header
                HStack {
                    // Dataset Selector Menu
                    Menu {
                        Button {
                            viewModel.selectedTab = .all
                        } label: {
                            HStack {
                                Text("All Shipments")
                                Image(systemName: "box.truck")
                            }
                        }
                        
                        Button {
                            viewModel.selectedTab = .active
                        } label: {
                            HStack {
                                Text("Active")
                                Image(systemName: "truck.box")
                            }
                        }
                        
                        Button {
                            viewModel.selectedTab = .history
                        } label: {
                            HStack {
                                Text("History")
                                Image(systemName: "clock")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedTab.rawValue)
                                .font(.system(.subheadline, design: .default).weight(.medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#ECE6DF"), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "#FDFBF8"))
                
                // Shipment List
                ScrollView {
                    LazyVStack(spacing: 24) {
                        if viewModel.isLoading {
                            ForEach(0..<4, id: \.self) { _ in
                                ShipmentSkeletonView()
                            }
                        } else if viewModel.filteredShipments.isEmpty {
                            EmptyStateView(
                                iconName: "shippingbox",
                                message: "No Active Shipments",
                                description: "New shipments will appear here after vendor dispatch is confirmed."
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(viewModel.filteredShipments) { shipment in
                                NavigationLink(value: AppDestination.shipmentTracking(shipment)) {
                                    ShipmentCardView(shipment: shipment)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(hex: "#FDFBF8").ignoresSafeArea())
            .navigationTitle("Shipments")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search shipments")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    NavigationLink(value: AppDestination.createVendorRequest(prefilledRequest: nil)) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                    }
                    
                    Button {
                        showingFilterSheet = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .font(.system(size: 18, weight: .medium))
                            
                            if viewModel.activeFilterCount > 0 {
                                Text("\(viewModel.activeFilterCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 14, height: 14)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }
                        .frame(width: 32, height: 32)
                    }
                }
            }
            .navigationDestination(for: AppDestination.self) { destination in
                Group {
                    switch destination {
                    case .vendorRequestDetail(let request):
                        VendorRequestDetailView(request: request)
                    case .createVendorRequest(let request):
                        CreateVendorRequestView(prefilledRequest: request)
                    case .shipmentTracking(let shipment):
                        ShipmentTrackingView(initialShipment: shipment)
                    case .asnDetails(let shipmentId):
                        ASNDetailsView(shipmentId: shipmentId)
                    case .qrScanner(let asn):
                        QRScannerView(asn: asn)
                    case .receivingSummary(let session):
                        QuantityVarianceView(session: session)
                    case .reviewVarianceImpact(let session):
                        ReviewVarianceImpactView(session: session)
                    case .confirmVarianceCompletion(let session):
                        ConfirmVarianceCompletionView(session: session)
                    case .receivingComplete(let session):
                        ReceivingCompleteView(session: session)
                    case .optionalVerification(let sku):
                        OptionalVerificationView(sku: sku)
                    default:
                        EmptyView()
                    }
                }
                .toolbar(.hidden, for: .tabBar)
            }
            .sheet(isPresented: $showingFilterSheet) {
                ShipmentsFilterSheet(selectedStatuses: $viewModel.selectedStatuses, selectedETA: $viewModel.selectedETA)
                    .presentationDetents([.medium, .large])
            }
            .task {
                await viewModel.loadData()
            }
        }
        .id(resetID)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PopToRoot"))) { _ in
            resetID = UUID()
        }
    }
}


#Preview {
    NavigationStack {
        ShipmentsDashboardView()
            .environmentObject(ShipmentsViewModel())
    }
}
