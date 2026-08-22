import SwiftUI
import PhotosUI

// MARK: - Create Planogram View

struct CreatePlanogramView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Form States
    @State private var planogramName = ""
    @State private var selectedCategory = "Handbags"
    @State private var description = ""
    @State private var effectiveDate = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 4)) ?? Date()
    @State private var versionNumber = "1.0"
    
    // Guidelines content
    @State private var guidelines = "• Premium handbags on eye-level shelves\n• New arrivals on center podium\n• Maintain 30 cm spacing between items\n• Display matching accessories together"
    
    // Assign boutiques check list states
    @State private var assignedBoutiques: Set<String> = []
    
    // Email notify toggle
    @State private var notifyManagers = true
    
    private let categories = ["Handbags", "Footwear", "Watches"]
    
    // File upload states
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var documentData: Data? = nil
    @State private var documentName: String? = nil
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header back label
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Planograms")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.primaryGold)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    HStack {
                        Text("New Planogram")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    // Card 1: Basic Details Form
                    basicDetailsCard
                    
                    // Card 2: Assets Upload Panels
                    assetsUploadCard
                    
                    // Card 3: Display Guidelines
                    displayGuidelinesCard
                    
                    // Card 4: Assign Boutiques
                    assignBoutiquesCard
                    
                    // Card 5: Notify Switch
                    notifyManagersCard
                    
                    // Bottom Buttons
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.95, green: 0.93, blue: 0.88))
                        .cornerRadius(14)
                        
                        Button("Publish") {
                            Task { await saveAndDismiss(status: "Published") }
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(14)
                    }
                    .disabled(isSaving)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Subviews: Basic Details
    
    private var basicDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BASIC DETAILS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            // Planogram Name
            VStack(alignment: .leading, spacing: 6) {
                formLabel("PLANOGRAM NAME")
                TextField("e.g. Luxury Handbag Display", text: $planogramName)
                    .font(.system(size: 15))
                    .padding(14)
                    .background(MatteTheme.Colors.dashboardBackground)
                    .cornerRadius(12)
            }
            
            // Category Selector
            VStack(alignment: .leading, spacing: 6) {
                formLabel("CATEGORY")
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { cat in
                        let isSelected = selectedCategory == cat
                        Button(action: { selectedCategory = cat }) {
                            Text(cat)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(isSelected ? .white : MatteTheme.Colors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSelected ? Color.black : Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.clear : MatteTheme.Colors.border, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Description Input
            VStack(alignment: .leading, spacing: 6) {
                formLabel("DESCRIPTION")
                TextEditor(text: $description)
                    .font(.system(size: 14))
                    .frame(height: 80)
                    .padding(10)
                    .background(MatteTheme.Colors.dashboardBackground)
                    .cornerRadius(12)
                    .overlay(
                        Group {
                            if description.isEmpty {
                                Text("Describe the merchandising intent...")
                                    .font(.system(size: 14))
                                    .foregroundColor(MatteTheme.Colors.textTertiary)
                                    .padding(.leading, 14)
                                    .padding(.top, 14)
                            }
                        }, alignment: .topLeading
                    )
            }
            
            // Effective Date & Version side-by-side
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    formLabel("EFFECTIVE DATE")
                    DatePicker("", selection: $effectiveDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "en_GB"))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(MatteTheme.Colors.dashboardBackground)
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    formLabel("VERSION NUMBER")
                    TextField("1.0", text: $versionNumber)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(MatteTheme.Colors.dashboardBackground)
                        .cornerRadius(10)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    // MARK: - Subviews: Assets Upload
    
    private var assetsUploadCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ASSETS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            // Image Upload Dashed Row
            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                uploadDashedButton(
                    title: documentName ?? "Upload Layout Images",
                    subtitle: documentName != nil ? "Image selected" : "JPG, PNG up to 20 MB each",
                    icon: documentName != nil ? "checkmark.circle.fill" : "photo.on.rectangle"
                )
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        documentData = data
                        documentName = "image-\(UUID().uuidString.prefix(8)).jpg"
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    private func uploadDashedButton(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(MatteTheme.Colors.primaryGold.opacity(0.06))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.doc")
                    .font(.system(size: 14))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
            }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    style: StrokeStyle(lineWidth: 1, dash: [4])
                )
                .foregroundColor(MatteTheme.Colors.border)
        )
    }
    
    // MARK: - Subviews: Display Guidelines
    
    private var displayGuidelinesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DISPLAY GUIDELINES")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            TextEditor(text: $guidelines)
                .font(.system(.body, design: .monospaced))
                .frame(height: 120)
                .padding(12)
                .background(MatteTheme.Colors.dashboardBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(MatteTheme.Colors.border, lineWidth: 1))
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    // MARK: - Subviews: Assign Boutiques
    
    private var assignBoutiquesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ASSIGN BOUTIQUES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textTertiary)
                
                Spacer()
                
                Text("\(assignedBoutiques.count) Selected")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MatteTheme.Colors.primaryGold.opacity(0.08))
                    .cornerRadius(6)
            }
            
            let groupedStores = Dictionary(grouping: authManager.supabaseStores, by: { $0.region })
            let sortedRegions = groupedStores.keys.sorted()
            
            VStack(spacing: 8) {
                if sortedRegions.isEmpty {
                    Text("No stores available.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.vertical, 10)
                } else {
                    ForEach(sortedRegions, id: \.self) { region in
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 8) {
                                let storesInRegion = (groupedStores[region] ?? []).sorted { $0.name < $1.name }
                                ForEach(storesInRegion, id: \.id) { store in
                                    boutiqueCheckbox(store.name)
                                }
                            }
                            .padding(.leading, 12)
                            .padding(.top, 8)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "globe")
                                    .foregroundColor(MatteTheme.Colors.primaryGold)
                                Text(region)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(MatteTheme.Colors.textPrimary)
                            }
                        }
                        .padding(12)
                        .background(MatteTheme.Colors.dashboardBackground)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    private func boutiqueCheckbox(_ name: String) -> some View {
        let isChecked = assignedBoutiques.contains(name)
        return Button(action: {
            if isChecked {
                assignedBoutiques.remove(name)
            } else {
                assignedBoutiques.insert(name)
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(isChecked ? Color.black : MatteTheme.Colors.textTertiary)
                
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.leading, 16)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Subviews: Notify Managers Switch
    
    private var notifyManagersCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $notifyManagers) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notify Boutique Managers")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    Text("Automatically email every assigned Boutique Manager")
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
            }
            .tint(Color.black)
            
            if notifyManagers {
                VStack(alignment: .leading, spacing: 10) {
                    Text("EMAIL WILL INCLUDE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        emailTickItem("Planogram PDF")
                        emailTickItem("Display Images")
                        emailTickItem("Instructions")
                        emailTickItem("Effective Date & Version")
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.98, green: 0.97, blue: 0.95))
                .cornerRadius(12)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    private func emailTickItem(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(MatteTheme.Colors.primaryGold)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
    }
    
    // MARK: - Helpers
    
    private func saveAndDismiss(status: String) async {
        isSaving = true
        let name = planogramName.isEmpty ? "Luxury Handbag Display" : planogramName
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: effectiveDate)
        
        let newPlanogram = SupabasePlanogram(
            id: UUID(),
            title: name,
            version: versionNumber,
            category: selectedCategory,
            effectiveDate: dateString,
            boutiquesAssigned: assignedBoutiques.count,
            createdBy: nil,
            status: status,
            documentURL: nil,
            createdAt: nil
        )
        
        do {
            try await authManager.createPlanogram(newPlanogram, documentData: documentData, fileName: documentName)
            isSaving = false
            presentationMode.wrappedValue.dismiss()
        } catch {
            isSaving = false
            errorMessage = "Failed to create planogram. Error: \(error.localizedDescription)\n\nEnsure the 'Planograms' bucket has an INSERT policy for authenticated users."
            showError = true
        }
    }
    
    private func formLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(MatteTheme.Colors.textTertiary)
    }
}
