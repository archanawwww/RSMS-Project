import SwiftUI

struct AuditLogsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var auditSearchText = ""
    @State private var auditFilterAction: AuditAction? = nil
    
    private var governanceAuditLogs: [AuditLog] {
        let allowedModules: Set<String> = ["Boutique Manager", "Inventory Controller", "Policies", "Corporate Admin"]
        return authManager.productAuditLogs.filter { allowedModules.contains($0.tableName) }
    }

    private var filteredAuditLogs: [AuditLog] {
        var result = governanceAuditLogs
        if let actionFilter = auditFilterAction {
            result = result.filter { $0.action == actionFilter }
        }
        guard !auditSearchText.isEmpty else { return result }
        let query = auditSearchText.lowercased()
        return result.filter {
            $0.tableName.lowercased().contains(query)
            || $0.action.rawValue.lowercased().contains(query)
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Table
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header Row
                        HStack(spacing: 24) {
                            Text("MODULE").frame(width: 160, alignment: .leading)
                            Text("ACTION").frame(width: 80, alignment: .leading)
                            Text("DETAILS").frame(width: 200, alignment: .leading)
                            HStack(spacing: 4) {
                                Text("CREATED ON")
                                Image(systemName: "chevron.up.chevron.down")
                            }.frame(width: 120, alignment: .leading)
                            HStack(spacing: 4) {
                                Text("UPDATED ON")
                                Image(systemName: "chevron.up.chevron.down")
                            }.frame(width: 120, alignment: .leading)
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider()
                        
                        let logs = filteredAuditLogs
                        if logs.isEmpty {
                            Text("No audit entries found.")
                                .font(MatteTheme.Typography.subheadline)
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                .padding(.vertical, 32)
                        } else {
                            ForEach(logs) { log in
                                AuditLogRowView(log: log)
                                if log.id != logs.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
                    .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                }
            }
            .padding(.top, MatteTheme.Spacing.lg)
            .padding(.bottom, 100)
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationTitle("Audit Logs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { auditFilterAction = nil }) {
                        Label("All Actions", systemImage: auditFilterAction == nil ? "checkmark" : "")
                    }
                    Button(action: { auditFilterAction = .create }) {
                        Label("Create", systemImage: auditFilterAction == .create ? "checkmark" : "")
                    }
                    Button(action: { auditFilterAction = .update }) {
                        Label("Update", systemImage: auditFilterAction == .update ? "checkmark" : "")
                    }
                    Button(action: { auditFilterAction = .delete }) {
                        Label("Delete", systemImage: auditFilterAction == .delete ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                        .frame(width: 36, height: 36)
                        .background(MatteTheme.Colors.luxuryGold.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
    }
}
    


// MARK: - AuditLogRowView
struct AuditLogRowView: View {
    let log: AuditLog
    
    var body: some View {
        HStack(spacing: 24) {
            // MODULE
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(moduleColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: moduleIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(moduleColor)
                }
                Text(moduleName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            .frame(width: 160, alignment: .leading)
            
            // ACTION
            Text(log.action.rawValue.capitalized)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(actionColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(actionColor.opacity(0.12))
                .cornerRadius(8)
                .frame(width: 80, alignment: .leading)
            
            // DETAILS
            VStack(alignment: .leading, spacing: 4) {
                Text(detailsTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text(detailsSubtitle)
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .lineLimit(2)
            }
            .frame(width: 200, alignment: .leading)
            
            // CREATED ON
            dateView(date: log.modifiedAt)
                .frame(width: 120, alignment: .leading)
            
            // UPDATED ON
            dateView(date: log.modifiedAt)
                .frame(width: 120, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var moduleName: String {
        log.tableName
    }
    
    private var moduleIcon: String {
        switch log.tableName {
        case "Inventory Controller": return "cube.box.fill"
        case "Boutique Manager": return "building.2.fill"
        case "Policies": return "doc.text.fill"
        case "ProductMasterRecord": return "shippingbox.fill"
        default: return "person.crop.circle.fill"
        }
    }
    
    private var moduleColor: Color {
        switch log.tableName {
        case "Inventory Controller": return .purple
        case "Boutique Manager": return .orange
        case "Policies": return MatteTheme.Colors.success
        case "ProductMasterRecord": return .blue
        default: return MatteTheme.Colors.primaryGold
        }
    }
    
    private var actionColor: Color {
        switch log.action {
        case .create: return MatteTheme.Colors.success
        case .update: return .blue
        case .delete: return MatteTheme.Colors.error
        }
    }
    
    private var detailsTitle: String {
        if log.tableName == "Policies" {
            return "Policy \(log.action.rawValue.capitalized)"
        }
        return log.tableName
    }
    
    private var detailsSubtitle: String {
        if let newV = log.newValues, !newV.isEmpty {
            return newV
        }
        if let prevV = log.previousValues, !prevV.isEmpty {
            return prevV
        }
        return "System generated"
    }
    
    private func dateView(date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let dateStr = formatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        let timeStr = timeFormatter.string(from: date)
        
        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .foregroundColor(MatteTheme.Colors.textTertiary)
                Text(dateStr)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .foregroundColor(MatteTheme.Colors.textTertiary)
                Text(timeStr)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
        }
        .font(.system(size: 11, weight: .medium))
    }
}
