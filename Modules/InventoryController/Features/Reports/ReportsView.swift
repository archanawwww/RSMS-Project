import SwiftUI

// MARK: - Reports List

struct ReportsView: View {

    @StateObject private var store  = ReportsStore.shared
    @State private var searchText  = ""
    @State private var filter      = ReportFilter()
    @State private var showFilter  = false

    // MARK: Computed

    private var processed: [ReportRecord] {
        var records = store.records

        // Type
        if let t = filter.type    { records = records.filter { $0.type   == t } }
        // Status
        if let s = filter.status  { records = records.filter { $0.status == s } }

        // Date range
        let cal = Calendar.current
        let now = Date()
        switch filter.dateRange {
        case .today:
            let start = cal.startOfDay(for: now)
            records = records.filter { $0.timestamp >= start }
        case .last7Days:
            let cutoff = cal.date(byAdding: .day, value: -7, to: now)!
            records = records.filter { $0.timestamp >= cutoff }
        case .last30Days:
            let cutoff = cal.date(byAdding: .day, value: -30, to: now)!
            records = records.filter { $0.timestamp >= cutoff }
        case .allTime:
            break
        }

        // Search
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            records = records.filter {
                $0.entityName.lowercased().contains(q)     ||
                ($0.entityId?.lowercased().contains(q) ?? false) ||
                $0.type.rawValue.lowercased().contains(q)  ||
                ($0.reason?.lowercased().contains(q) ?? false)   ||
                $0.id.lowercased().contains(q)             ||
                $0.summary.lowercased().contains(q)
            }
        }

        // Sort
        switch filter.sortOrder {
        case .newestFirst: records.sort { $0.timestamp > $1.timestamp }
        case .oldestFirst: records.sort { $0.timestamp < $1.timestamp }
        }

        return records
    }

    private var groups: [ReportDateGroup] {
        let cal           = Calendar.current
        let todayStart    = cal.startOfDay(for: Date())
        let yesterStart   = cal.date(byAdding: .day, value: -1, to: todayStart)!

        var todayRecs:  [ReportRecord] = []
        var yesterRecs: [ReportRecord] = []
        var otherRecs:  [ReportRecord] = []

        for r in processed {
            let day = cal.startOfDay(for: r.timestamp)
            if      day >= todayStart  { todayRecs.append(r) }
            else if day >= yesterStart { yesterRecs.append(r) }
            else                       { otherRecs.append(r) }
        }

        var out: [ReportDateGroup] = []
        if !todayRecs.isEmpty  { out.append(.init(id: "today",     title: "Today",     records: todayRecs)) }
        if !yesterRecs.isEmpty { out.append(.init(id: "yesterday", title: "Yesterday", records: yesterRecs)) }
        if !otherRecs.isEmpty  { out.append(.init(id: "earlier",   title: "Earlier",   records: otherRecs)) }
        return out
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            if groups.isEmpty {
                emptyStateView
            } else {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(groups) { group in
                                ReportDateSectionView(group: group)
                                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Reports")
        .searchable(text: $searchText, prompt: "Search reports")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showFilter = true } label: {
                    Image(systemName: filter.isActive
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                    .foregroundColor(Color(UIColor.label))
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            ReportFilterSheet(filter: $filter)
        }
    }

    

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 42, weight: .ultraLight))
                .foregroundColor(Color(UIColor.systemGray3))
            Text("No Reports Found")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
            Text("No records match your current search or filter.")
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .padding(.horizontal, 48)
    }
}


private struct ReportDateSectionView: View {
    let group: ReportDateGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

         
         

            // Single grouped card — rows separated by hairlines
            VStack(spacing: 0) {
                ForEach(Array(group.records.enumerated()), id: \.element.id) { idx, record in
                    NavigationLink(destination: ReportDetailView(record: record)) {
                        ReportRecordRow(record: record)
                    }
                    .buttonStyle(.plain)

                    if idx < group.records.count - 1 {
                        // Inset separator: left-pad past icon (16 + 40 + 12)
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(Spacing.Shadow.opacity),
                    radius: Spacing.Shadow.radius, x: 0, y: Spacing.Shadow.yOffset)
        }
    }
}

// MARK: - Record Row

private struct ReportRecordRow: View {
    let record: ReportRecord

    var body: some View {
        HStack(spacing: 12) {

            // Icon circle
            ZStack {
                Circle()
                    .fill(record.type.iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: record.type.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(record.type.iconColor)
            }

            // Three-line content
            VStack(alignment: .leading, spacing: 2) {
                // Line 1 — record type (bold)
                Text(record.type.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                    .lineLimit(1)

                // Line 2 — entity name + ID
                Text(entityLabel)
                    .font(.system(size: 13))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .lineLimit(1)

                // Line 3 — summary
                Text(record.summary)
                    .font(.system(size: 13))
                    .foregroundColor(summaryColor)

                // Line 4 — timestamp (operationally necessary for record browser)
                Text(formattedTimestamp)
                    .font(.system(size: 11))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .padding(.top, 1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color.theme.surface)
        .contentShape(Rectangle())
    }

    private var entityLabel: String {
        if let eid = record.entityId {
            return "\(eid)  ·  \(record.entityName)"
        }
        return record.entityName
    }

    private var summaryColor: Color {
        guard let diff = record.difference else { return Color(UIColor.secondaryLabel) }
        if diff < 0 { return Color(UIColor.systemRed) }
        if diff > 0 { return Color(UIColor.systemOrange) }
        return Color(UIColor.systemGreen)
    }

    private var formattedTimestamp: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy  ·  h:mm a"
        return f.string(from: record.timestamp)
    }
}

// MARK: - Filter Sheet

struct ReportFilterSheet: View {
    @Binding var filter: ReportFilter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Type
                    filterSection("Type") {
                        filterRow("All Types", selected: filter.type == nil) {
                            filter.type = nil
                        }
                        ForEach(ReportType.allCases) { t in
                            Divider().padding(.leading, 16)
                            filterRow(t.rawValue, selected: filter.type == t) {
                                filter.type = (filter.type == t) ? nil : t
                            }
                        }
                    }

                    // Status filter removed — synchronization state hidden from UI

                    // Date Range
                    filterSection("Date Range") {
                        ForEach(Array(ReportDateRange.allCases.enumerated()), id: \.element.id) { i, r in
                            if i > 0 { Divider().padding(.leading, 16) }
                            filterRow(r.rawValue, selected: filter.dateRange == r) {
                                filter.dateRange = r
                            }
                        }
                    }

                    // Sort Order
                    filterSection("Sort") {
                        ForEach(Array(ReportSortOrder.allCases.enumerated()), id: \.element.id) { i, s in
                            if i > 0 { Divider().padding(.leading, 16) }
                            filterRow(s.rawValue, selected: filter.sortOrder == s) {
                                filter.sortOrder = s
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Filter Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        withAnimation(.easeInOut(duration: 0.2)) { filter = ReportFilter() }
                    }
                    .foregroundColor(filter.isActive ? Color(UIColor.systemBlue) : Color(UIColor.tertiaryLabel))
                    .disabled(!filter.isActive)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: Section builder

    @ViewBuilder
    private func filterSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .textCase(.uppercase)
                .tracking(0.4)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
        }
    }

    private func filterRow(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.accent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color.theme.surface)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReportsView()
    }
}
