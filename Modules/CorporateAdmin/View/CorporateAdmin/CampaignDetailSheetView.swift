import SwiftUI

// MARK: - Campaign Detail Sheet View

struct CampaignDetailSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @EnvironmentObject var authManager: AuthenticationManager
    let campaign: SupabaseCampaign
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSendingEmail = false
    
    // Track expanded countries in the list
    @State private var expandedCountries: Set<String> = ["India"]
    
    // Mock list of boutique recipients matching mockup names and emails
    private let recipients = [
        RecipientItem(name: "Delhi Boutique II", city: "Delhi", country: "India", email: "manager.delhi@luxora.com"),
        RecipientItem(name: "Mumbai Boutique I", city: "Mumbai", country: "India", email: "manager.mumbai@luxora.com"),
        RecipientItem(name: "Bangalore Boutique", city: "Bangalore", country: "India", email: "manager.bangalore@luxora.com"),
        RecipientItem(name: "Hyderabad Boutique", city: "Hyderabad", country: "India", email: "manager.hyd@luxora.com"),
        RecipientItem(name: "Chennai Boutique", city: "Chennai", country: "India", email: "manager.chennai@luxora.com"),
        RecipientItem(name: "Berlin Boutique I", city: "Berlin", country: "Germany", email: "manager.berlin@luxora.com"),
        RecipientItem(name: "Paris Boutique I", city: "Paris", country: "France", email: "manager.paris@luxora.com")
    ]
    
    private var groupedRecipients: [(country: String, items: [RecipientItem])] {
        let grouped = Dictionary(grouping: recipients, by: { $0.country })
        return grouped.map { (country: $0.key, items: $0.value) }.sorted { $0.country < $1.country }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Close Button
            sheetHeaderView
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Campaign details tag (Discount type & Start/End Dates)
                    campaignSpecsSection
                    
                    // Recipients Section Title
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recipients")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                        
                        // Recipient list grouped by country
                        VStack(spacing: 12) {
                            ForEach(groupedRecipients, id: \.country) { group in
                                countryGroupView(country: group.country, items: group.items)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            
            // Fixed bottom golden action button
            bottomActionButton
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white.shadow(color: Color.black.opacity(0.04), radius: 6, y: -3))
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Email Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Subviews: Header
    
    private var sheetHeaderView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Shared With")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text(campaign.title)
                    .font(.system(size: 15))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            Spacer()
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Color.black.opacity(0.04))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Subviews: Campaign Specs
    
    private var campaignSpecsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                Text("Type:")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                Text(campaign.type)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                Text("Duration:")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                Text(formatPeriod(start: campaign.startDate, end: campaign.endDate))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
        }
        .padding(14)
        .background(MatteTheme.Colors.primaryGold.opacity(0.04))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(MatteTheme.Colors.primaryGold.opacity(0.12), lineWidth: 1))
    }
    
    // MARK: - Helpers
    
    private func formatPeriod(start: String, end: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        
        let sDate = inputFormatter.date(from: start) ?? Date()
        let eDate = inputFormatter.date(from: end) ?? Date()
        
        return "\(outputFormatter.string(from: sDate)) – \(outputFormatter.string(from: eDate))"
    }
    
    // MARK: - Subviews: Recipient Group
    
    private func countryGroupView(country: String, items: [RecipientItem]) -> some View {
        let isExpanded = expandedCountries.contains(country)
        
        return VStack(spacing: 0) {
            Button(action: {
                if isExpanded {
                    expandedCountries.remove(country)
                } else {
                    expandedCountries.insert(country)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.system(size: 14))
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                    Text(country)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(14)
                .background(MatteTheme.Colors.dashboardBackground)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        recipientRow(item: item)
                        if item.id != items.last?.id {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .background(Color.white)
            }
        }
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
        .clipped()
    }
    
    private func recipientRow(item: RecipientItem) -> some View {
        HStack(spacing: 14) {
            // Left store icon
            ZStack {
                Circle()
                    .fill(MatteTheme.Colors.primaryGold.opacity(0.08))
                    .frame(width: 34, height: 34)
                Image(systemName: "storefront.fill")
                    .font(.system(size: 13))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                
                HStack(spacing: 6) {
                    Text(item.city)
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    Text("•")
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    Text(item.country)
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
                
                Text(item.email)
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Envelope button
            Button(action: {
                if let url = URL(string: "mailto:\(item.email)") {
                    openURL(url)
                }
            }) {
                Image(systemName: "envelope")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(MatteTheme.Colors.primaryGold.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
    }
    
    // MARK: - Bottom Action Button
    
    private var bottomActionButton: some View {
        Button(action: {
            let allEmails = recipients.map { $0.email }
            isSendingEmail = true
            Task {
                do {
                    let success = try await authManager.sendCampaignEmail(campaign: campaign, recipients: allEmails)
                    await MainActor.run {
                        isSendingEmail = false
                        if success {
                            alertMessage = "Mail sent successfully via Supabase!"
                        } else {
                            alertMessage = "Mail failed to send."
                        }
                        showingAlert = true
                    }
                } catch {
                    await MainActor.run {
                        isSendingEmail = false
                        alertMessage = "Error: \(error.localizedDescription)"
                        showingAlert = true
                    }
                }
            }
        }) {
            HStack(spacing: 8) {
                if isSendingEmail {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Email All Managers")
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(MatteTheme.Colors.primaryGold)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .disabled(isSendingEmail)
    }
}

// MARK: - Supporting Types

struct RecipientItem: Identifiable {
    var id: UUID = UUID()
    var name: String
    var city: String
    var country: String
    var email: String
}
