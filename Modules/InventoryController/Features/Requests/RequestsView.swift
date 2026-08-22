import SwiftUI

struct RequestsView: View {
    @StateObject private var viewModel = RequestsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.theme.textSecondary)
                    TextField("Search requests...", text: $viewModel.searchText)
                }
                .padding(10)
                .background(Color.theme.surface)
                .cornerRadius(10)
                .padding(.horizontal, Spacing.standard)
                .padding(.top, Spacing.small)
                
                // Segmented Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.standard) {
                        FilterButton(title: "All", isSelected: viewModel.selectedFilter == nil) {
                            viewModel.selectedFilter = nil
                        }
                        
                        ForEach(RequestStatus.requestFilters, id: \.self) { status in
                            FilterButton(title: status.displayName, isSelected: viewModel.selectedFilter == status) {
                                viewModel.selectedFilter = status
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.standard)
                    .padding(.vertical, Spacing.standard)
                }
                
                // List
                if viewModel.filteredRequests.isEmpty {
                    EmptyStateView(iconName: "doc.text.magnifyingglass", message: "No requests found.")
                } else {
                    List {
                        ForEach(viewModel.filteredRequests) { request in
                            ZStack {
                                RequestRow(request: request)
                                NavigationLink(value: AppDestination.requestDetail(request)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: Spacing.standard, bottom: 4, trailing: Spacing.standard))
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.theme.background)
                }
            }
            .navigationTitle("Requests")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: AppDestination.self) { dest in
                if case .requestDetail(let req) = dest {
                    RequestDetailView(request: req, viewModel: viewModel)
                }
                if case .createVendorRequest(let req) = dest {
                    // Navigate to Vendor Request Creation
                    CreateVendorRequestView(prefilledRequest: req)
                }
            }
            .task {
                await viewModel.loadRequests()
            }
            .background(Color.theme.background.ignoresSafeArea())
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.subheadline.weight(isSelected ? .bold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.theme.accent : Color.theme.surface)
                .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
                .cornerRadius(20)
        }
    }
}

struct RequestRow: View {
    let request: StoreRequest
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text(request.productName)
                        .font(Typography.headline)
                    Spacer()
                    StatusBadge(status: request.status.displayName)
                }
                
                Text(request.storeName)
                    .font(Typography.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
                
                HStack {
                    Text(request.id)
                        .font(Typography.body)
                        .foregroundColor(Color.theme.textPrimary)
                    Spacer()
                    Text("Qty: \(request.quantityRequested)")
                        .font(Typography.body.weight(.bold))
                }
                
                HStack {
                    Text("Type: \(request.requestType.rawValue)")
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textTertiary)
                    Spacer()
                    Text(request.createdAt, style: .date)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textTertiary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RequestsView()
            .environmentObject(ShipmentsViewModel())
    }
}
