import SwiftUI

struct CycleCountView: View {
    @ObservedObject private var store = CycleCountStore.shared
    @EnvironmentObject var appState: InventoryAppState
    
    var searchText: String = ""
    @State private var selectedTab = "Scheduled"
    @State private var showNewCycleCount = false
    
    private var scheduledCount: Int {
        store.sessions.filter { $0.status == .pending }.count
    }
    
    private var inProgressCount: Int {
        store.sessions.filter { $0.status == .inProgress }.count
    }
    
    private var pendingApprovalCount: Int {
        store.sessions.filter { $0.status == .completed && !$0.isResolved }.count
    }
    
    private var completedCount: Int {
        store.sessions.filter { $0.status == .completed && $0.isResolved }.count
    }
    
    private var displayedSessions: [CycleCountSession] {
        var sessions = store.sessions
        if !searchText.isEmpty {
            sessions = sessions.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch selectedTab {
        case "Scheduled":
            return sessions.filter { $0.status == .pending }
        case "In Progress":
            return sessions.filter { $0.status == .inProgress }
        case "Pending Approval":
            return sessions.filter { $0.status == .completed && !$0.isResolved }
        case "Completed":
            return sessions.filter { $0.status == .completed && $0.isResolved }
        default:
            return sessions
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if let error = store.loadError {
                        errorView(error)
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Status Tabs
                                statusTabs
                                
                                // Summary Cards Grid
                                summaryGrid
                                    .padding(.horizontal, 16)
                                
                                // List Section
                                listSection
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 32)
                        }
                        .refreshable {
                            await store.loadFromSupabase()
                        }
                    }
                }
            }
            .navigationTitle("Cycle Counts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Notifications or similar
                    } label: {
                        Image(systemName: "bell")
                            .foregroundColor(Color.theme.textPrimary)
                    }
                }
            }
            .navigationDestination(item: $appState.activeCycleCountSession) { session in
                destinationView(for: session)
                    .onAppear { appState.activeCycleCountSession = nil }
            }
            .navigationDestination(isPresented: $showNewCycleCount) {
                NewCycleCountView()
            }
            .task {
                await store.loadFromSupabase()
            }
        }
    }
    
    // MARK: - Components
    
    private var statusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["Scheduled", "In Progress", "Pending Approval", "Completed"], id: \.self) { tab in
                    Button {
                        withAnimation {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab)
                            .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedTab == tab ? Color.theme.brand : Color.theme.surface
                            )
                            .foregroundColor(
                                selectedTab == tab ? .white : Color.theme.textSecondary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.theme.border, lineWidth: selectedTab == tab ? 0 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var summaryGrid: some View {
        HStack(spacing: 12) {
            summaryCard(title: "Scheduled", icon: "calendar", count: scheduledCount)
            summaryCard(title: "In Progress", icon: "arrow.triangle.2.circlepath", count: inProgressCount)
            summaryCard(title: "Pending", icon: "person.crop.circle.badge.checkmark", count: pendingApprovalCount)
            summaryCard(title: "Completed", icon: "checkmark.circle", count: completedCount)
        }
    }
    
    private func summaryCard(title: String, icon: String, count: Int) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color.theme.brand)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.theme.textPrimary)
            
            Text("Counts")
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
    private var listSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(selectedTab) Counts")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                Spacer()
                Button("See All") {
                    // action
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.theme.brand)
            }
            .padding(.horizontal, 16)
            
            LazyVStack(spacing: 12) {
                ForEach(displayedSessions) { session in
                    NavigationLink(destination: destinationView(for: session)) {
                        CycleCountRowCard(session: session)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(Color.theme.textSecondary)
            Text("Could not load cycle counts")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.theme.textPrimary)
            Text(error)
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Retry") {
                store.loadError = nil
                Task { await store.loadFromSupabase() }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color.theme.brand)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.theme.brand.opacity(0.10))
            .clipShape(Capsule())
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func destinationView(for session: CycleCountSession) -> some View {
        switch session.status {
        case .pending:
            ScheduledCycleCountSummaryView(session: session)
        case .inProgress:
            CycleCountExecutionView(session: session)
        case .completed:
            CompletedCycleCountSummaryView(session: session)
        }
    }
}

// MARK: - Row Card

struct CycleCountRowCard: View {
    let session: CycleCountSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                    Text(session.location ?? "Main Warehouse")
                        .font(.system(size: 14))
                        .foregroundColor(Color.theme.textSecondary)
                }
                Spacer()
                Text(session.dateLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
            }
            
            // Subtitle / Type
            Text("Full Count")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)
            
            // Progress Bar if in progress
            if session.status == .inProgress {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.theme.border)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.theme.brand)
                                .frame(width: geo.size.width * session.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    HStack {
                        Text("\(session.counted) of \(session.total) items counted")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.textSecondary)
                        Spacer()
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Status Chip & Priority
            HStack {
                statusChip
                
                Spacer()
                
                if session.status == .pending {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(UIColor.systemRed))
                            .frame(width: 6, height: 6)
                        Text("Due Today")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(UIColor.systemRed).opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var statusChip: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIconName)
                .font(.system(size: 10, weight: .bold))
            Text(statusText)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (session.status == .pending || session.status == .completed) ? Color.clear : Color.theme.brand.opacity(0.1)
        )
        .foregroundColor(
            (session.status == .pending || session.status == .completed) ? Color.theme.textSecondary : Color.theme.brand
        )
        .overlay(
            Capsule().stroke(
                (session.status == .pending || session.status == .completed) ? Color.theme.border : Color.clear,
                lineWidth: 1
            )
        )
        .clipShape(Capsule())
    }
    
    private var statusText: String {
        switch session.status {
        case .pending: return "Scheduled"
        case .inProgress: return "In Progress"
        case .completed: return session.isResolved ? "Completed" : "Pending Approval"
        }
    }
    
    private var statusIconName: String {
        switch session.status {
        case .pending: return "calendar"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .completed: return session.isResolved ? "checkmark.circle.fill" : "person.crop.circle.badge.checkmark"
        }
    }
}
