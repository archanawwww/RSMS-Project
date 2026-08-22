import SwiftUI

enum CreateUserField: Hashable {
    case firstName, lastName, email, phone, password
}

enum PasswordStrength {
    case empty, weak, medium, strong
    
    var color: Color {
        switch self {
        case .empty: return .clear
        case .weak: return MatteTheme.Colors.error
        case .medium: return MatteTheme.Colors.warning
        case .strong: return MatteTheme.Colors.success
        }
    }
    
    var text: String {
        switch self {
        case .empty: return ""
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
}

struct ValidatedTextFieldStyle: ViewModifier {
    var error: String?
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .matteFieldStyle()
                .overlay(
                    RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.medium)
                        .stroke(error != nil ? MatteTheme.Colors.error : Color.clear, lineWidth: 1)
                )
            
            if let error = error, !error.isEmpty {
                Text(error)
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.error)
                    .padding(.leading, 8)
            }
        }
    }
}

extension View {
    func validatedField(error: String?) -> some View {
        self.modifier(ValidatedTextFieldStyle(error: error))
    }
}

struct CreateUserView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var newUsername = ""
    @State private var newPhoneNumber = ""
    @State private var newPassword = ""
    @State private var newFirstName = ""
    @State private var newLastName = ""
    @State private var newStoreID: UUID? = nil
    @State private var newRole: UserRole = .boutiqueManager
    @State private var newCountry: Country = .india
    @State private var showBoutiqueSheet = false
    @State private var statusMessage: String?
    
    // Validation State
    @State private var firstNameError: String? = nil
    @State private var lastNameError: String? = nil
    @State private var emailError: String? = nil
    @State private var phoneError: String? = nil
    @State private var passwordError: String? = nil
    @State private var storeError: String? = nil
    @State private var passwordStrength: PasswordStrength = .empty
    @State private var showPassword = false
    @State private var isSubmitting = false
    @State private var showSuccessToast = false
    
    @FocusState private var focusedField: CreateUserField?
    
    private var isFormValid: Bool {
        !newFirstName.isEmpty && firstNameError == nil &&
        !newLastName.isEmpty && lastNameError == nil &&
        !newUsername.isEmpty && emailError == nil &&
        !newPhoneNumber.isEmpty && phoneError == nil &&
        !newPassword.isEmpty && passwordError == nil &&
        (newRole == .corporateAdmin || newRole == .inventoryController || (newStoreID != nil && storeError == nil))
    }
    
    private var creatableRoles: [UserRole] {
        [.boutiqueManager, .inventoryController]
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: MatteTheme.Spacing.md) {
                    nameFields
                    emailField
                    phoneField
                    passwordField
                    storePicker
                    rolePicker
                    submitSection(scrollProxy: scrollProxy)
                    statusMessageView
                }
                .padding(16)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .onChange(of: focusedField) { newFocus in
                if newFocus != .firstName { validateFirstName(realtime: false) }
                if newFocus != .lastName { validateLastName(realtime: false) }
                if newFocus != .email { validateEmail(realtime: false) }
                if newFocus != .phone { validatePhone(realtime: false) }
                if newFocus != .password { validatePassword(realtime: false) }
            }
            .onChange(of: newStoreID) { _ in validateStore() }
            .onChange(of: newRole) { _ in validateStore() }
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationTitle("Create User")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Components
    
    private var nameFields: some View {
        HStack(alignment: .top, spacing: MatteTheme.Spacing.sm) {
            TextField("First Name", text: $newFirstName)
                .focused($focusedField, equals: .firstName)
                .submitLabel(.next)
                .validatedField(error: firstNameError)
                .onChange(of: newFirstName) { _ in validateFirstName(realtime: true) }
                .onSubmit { focusedField = .lastName }
                .id(CreateUserField.firstName)
            
            TextField("Last Name", text: $newLastName)
                .focused($focusedField, equals: .lastName)
                .submitLabel(.next)
                .validatedField(error: lastNameError)
                .onChange(of: newLastName) { _ in validateLastName(realtime: true) }
                .onSubmit { focusedField = .email }
                .id(CreateUserField.lastName)
        }
    }
    
    private var emailField: some View {
        TextField("Email", text: $newUsername)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)
            .validatedField(error: emailError)
            .onChange(of: newUsername) { _ in validateEmail(realtime: true) }
            .onSubmit { focusedField = .phone }
            .id(CreateUserField.email)
    }
    
    private var phoneField: some View {
        TextField("Phone Number", text: $newPhoneNumber)
            .focused($focusedField, equals: .phone)
            .submitLabel(.next)
            .keyboardType(.phonePad)
            .validatedField(error: phoneError)
            .onChange(of: newPhoneNumber) { _ in validatePhone(realtime: true) }
            .onSubmit { focusedField = .password }
            .id(CreateUserField.phone)
    }
    
    private var passwordField: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ZStack(alignment: .trailing) {
                if showPassword {
                    TextField("Password", text: $newPassword)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .validatedField(error: passwordError)
                } else {
                    SecureField("Password", text: $newPassword)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .validatedField(error: passwordError)
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                        .padding(.trailing, 16)
                        // Move up if there's an error so it stays inside the textfield
                        .padding(.bottom, passwordError != nil ? 20 : 0) 
                }
            }
            .onChange(of: newPassword) { _ in validatePassword(realtime: true) }
            .onSubmit { focusedField = nil }
            .id(CreateUserField.password)
            
            if !newPassword.isEmpty {
                Text("Strength: \(passwordStrength.text)")
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(passwordStrength.color)
            }
        }
    }
    
    @ViewBuilder
    private var storePicker: some View {
        if newRole == .boutiqueManager {
            VStack(alignment: .leading, spacing: 4) {
                Button {
                    showBoutiqueSheet = true
                } label: {
                    HStack {
                        Text(newStoreID == nil ? "Select a Store" : (authManager.availableSupabaseStores.first(where: { $0.id == newStoreID })?.name ?? "Select a Store"))
                            .foregroundColor(newStoreID == nil ? MatteTheme.Colors.textSecondary : MatteTheme.Colors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(MatteTheme.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.medium)
                            .stroke(storeError != nil ? MatteTheme.Colors.error : Color.gray.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showBoutiqueSheet) {
                    BoutiqueSelectionSheet(
                        selectedStoreID: $newStoreID,
                        availableStores: authManager.availableSupabaseStores
                    )
                    .presentationDetents([.fraction(0.9)])
                }
                
                if let storeError = storeError, !storeError.isEmpty {
                    Text(storeError)
                        .font(MatteTheme.Typography.caption)
                        .foregroundColor(MatteTheme.Colors.error)
                        .padding(.leading, 8)
                }
            }
        } else if newRole == .inventoryController {
            VStack(alignment: .leading, spacing: 8) {
                Text("Country")
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                
                Picker("Country", selection: $newCountry) {
                    ForEach(Country.allCases) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(MatteTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.medium)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    private var rolePicker: some View {
        Picker("Role", selection: $newRole) {
            ForEach(creatableRoles) { role in
                Text(role.rawValue).tag(role)
            }
        }
        .pickerStyle(.menu)
        .tint(MatteTheme.Colors.accent)
    }
    
    private func submitSection(scrollProxy: ScrollViewProxy) -> some View {
        let isFormInvalid = (firstNameError != nil || lastNameError != nil || emailError != nil || phoneError != nil || passwordError != nil)
        return Button(action: { submitForm(scrollProxy: scrollProxy) }) {
            HStack {
                Spacer()
                if isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Create Account")
                }
                Spacer()
            }
            .padding()
            .background(MatteTheme.Colors.primaryGold)
            .foregroundColor(.white)
            .font(MatteTheme.Typography.headline)
            .cornerRadius(MatteTheme.CornerRadius.medium)
            .opacity(isFormInvalid ? 0.6 : 1.0)
        }
        .disabled(isSubmitting)
    }
    
    @ViewBuilder
    private var statusMessageView: some View {
        if let statusMessage {
            Text(statusMessage)
                .font(MatteTheme.Typography.footnote)
                .foregroundColor(showSuccessToast ? MatteTheme.Colors.success : MatteTheme.Colors.error)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // MARK: - Validation Logic
    
    private func capitalizeAndTrim(_ text: inout String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.count > 0 {
            let firstChar = trimmed.prefix(1).capitalized
            let rest = trimmed.dropFirst()
            text = firstChar + rest
        } else {
            text = trimmed
        }
    }
    
    private func validateName(text: inout String, realtime: Bool, fieldName: String) -> String? {
        if realtime {
            capitalizeAndTrim(&text)
        } else {
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if text.isEmpty {
            return realtime ? nil : "\(fieldName) is required."
        }
        if text.count < 2 {
            return "\(fieldName) must contain at least 2 characters."
        }
        if text.count > 30 {
            return "\(fieldName) cannot exceed 30 characters."
        }
        
        let numbers = CharacterSet.decimalDigits
        if text.rangeOfCharacter(from: numbers) != nil {
            return "\(fieldName) cannot contain numbers."
        }
        
        let lettersAndSpaces = CharacterSet.letters.union(CharacterSet.whitespaces)
        let specialChars = text.unicodeScalars.filter { !lettersAndSpaces.contains($0) }
        if !specialChars.isEmpty {
            return "\(fieldName) cannot contain special characters."
        }
        
        return nil
    }
    
    private func validateFirstName(realtime: Bool) {
        firstNameError = validateName(text: &newFirstName, realtime: realtime, fieldName: "First name")
    }
    
    private func validateLastName(realtime: Bool) {
        lastNameError = validateName(text: &newLastName, realtime: realtime, fieldName: "Last name")
    }
    
    private func validateEmail(realtime: Bool) {
        if realtime {
            newUsername = newUsername.replacingOccurrences(of: " ", with: "").lowercased()
        }
        
        if newUsername.isEmpty {
            emailError = realtime ? nil : "Email is required."
            return
        }
        
        if newUsername.contains(" ") {
            emailError = "Email cannot contain spaces."
            return
        }
        
        if !newUsername.contains("@") {
            emailError = "Email must contain '@gmail.com'."
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: newUsername) {
            emailError = "Enter a valid email address."
            return
        }
        
        if !newUsername.hasSuffix("@gmail.com") {
            emailError = "Only Gmail addresses are allowed."
            return
        }
        
        // Uniqueness check
        if authManager.users.contains(where: { $0.email.lowercased() == newUsername.lowercased() }) {
            emailError = "Email already exists."
            return
        }
        
        emailError = nil
    }
    
    private func validatePhone(realtime: Bool) {
        if realtime {
            newPhoneNumber = newPhoneNumber.replacingOccurrences(of: " ", with: "")
            if newPhoneNumber.count > 10 {
                newPhoneNumber = String(newPhoneNumber.prefix(10))
            }
        }
        
        if newPhoneNumber.isEmpty {
            phoneError = realtime ? nil : "Phone number is required."
            return
        }
        
        if newPhoneNumber.contains(" ") {
            phoneError = "Phone number cannot contain spaces."
            return
        }
        
        let letters = CharacterSet.letters
        if newPhoneNumber.rangeOfCharacter(from: letters) != nil {
            phoneError = "Phone number cannot contain letters."
            return
        }
        
        let nonNumbers = CharacterSet.decimalDigits.inverted
        if newPhoneNumber.rangeOfCharacter(from: nonNumbers) != nil {
            phoneError = "Phone number can contain numbers only."
            return
        }
        
        if newPhoneNumber.count < 10 {
            phoneError = "Phone number must contain exactly 10 digits."
            return
        }
        
        if newPhoneNumber.count > 10 {
            phoneError = "Phone number must contain exactly 10 digits."
            return
        }
        
        // Uniqueness check
        if authManager.users.contains(where: { $0.phoneNumber == newPhoneNumber }) {
            phoneError = "Phone number already exists."
            return
        }
        
        phoneError = nil
    }
    
    private func validatePassword(realtime: Bool) {
        let pass = newPassword
        
        // Calculate strength
        var score = 0
        if pass.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if pass.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if pass.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        let special = CharacterSet.alphanumerics.inverted.subtracting(.whitespaces)
        if pass.rangeOfCharacter(from: special) != nil { score += 1 }
        
        if pass.isEmpty {
            passwordStrength = .empty
        } else if score <= 2 || pass.count < 8 {
            passwordStrength = .weak
        } else if score == 3 {
            passwordStrength = .medium
        } else if score >= 4 && pass.count >= 8 {
            passwordStrength = .strong
        }
        
        // Hard validation errors
        if pass.isEmpty {
            passwordError = realtime ? nil : "Password is required."
            return
        }
        
        if pass.contains(" ") {
            passwordError = "Password cannot contain spaces."
            return
        }
        
        if pass.count < 8 {
            passwordError = "Password must be at least 8 characters long."
            return
        }
        
        if pass.count > 20 {
            passwordError = "Password cannot exceed 20 characters."
            return
        }
        
        if pass.rangeOfCharacter(from: .uppercaseLetters) == nil {
            passwordError = "Password must contain at least one uppercase letter."
            return
        }
        if pass.rangeOfCharacter(from: .lowercaseLetters) == nil {
            passwordError = "Password must contain at least one lowercase letter."
            return
        }
        if pass.rangeOfCharacter(from: .decimalDigits) == nil {
            passwordError = "Password must contain at least one number."
            return
        }
        if pass.rangeOfCharacter(from: special) == nil {
            passwordError = "Password must contain at least one special character."
            return
        }
        
        let fName = newFirstName.trimmingCharacters(in: .whitespaces).lowercased()
        if !fName.isEmpty && pass.lowercased().contains(fName) {
            passwordError = "Password cannot contain your first name."
            return
        }
        
        let lName = newLastName.trimmingCharacters(in: .whitespaces).lowercased()
        if !lName.isEmpty && pass.lowercased().contains(lName) {
            passwordError = "Password cannot contain your last name."
            return
        }
        
        let emailUsername = newUsername.components(separatedBy: "@").first?.lowercased() ?? ""
        if !emailUsername.isEmpty && pass.lowercased().contains(emailUsername) {
            passwordError = "Password cannot contain your email name."
            return
        }
        
        // Uniqueness check (password matches another user)
        // Normally passwords are not checked like this in plaintext, but per spec, it must not match another manager's credentials.
        // We simulate this by checking if anyone else has this as their username or phone number just in case. But let's assume they don't want exact matching passwords.
        // For a real app, this is impossible due to hashing. We'll skip exact password matching check unless there's a stored cleartext field, which there shouldn't be. 
        // Wait, the spec says "Every manager must have unique credentials (email, phone nu..." which usually means email and phone. I will just check if they use their own phone number as password.
        if !newPhoneNumber.isEmpty && pass == newPhoneNumber {
            passwordError = "Password cannot be your phone number."
            return
        }
        
        passwordError = nil
    }
    
    private func validateStore() {
        if newRole == .boutiqueManager {
            guard let storeID = newStoreID else {
                storeError = "Please select an assigned store."
                return
            }
            let hasManager = authManager.users.contains { user in
                user.role == .boutiqueManager && user.assignedStoreID == storeID && user.isActive
            }
            if hasManager {
                storeError = "This boutique already has an assigned Boutique Manager."
            } else {
                storeError = nil
            }
        } else {
            storeError = nil
        }
    }
    
    private func submitForm(scrollProxy: ScrollViewProxy) {
        // Trigger all validations non-realtime to surface errors
        validateFirstName(realtime: false)
        validateLastName(realtime: false)
        validateEmail(realtime: false)
        validatePhone(realtime: false)
        validatePassword(realtime: false)
        validateStore()
        
        if firstNameError != nil {
            focusedField = .firstName
            withAnimation { scrollProxy.scrollTo(CreateUserField.firstName, anchor: .center) }
            return
        }
        if lastNameError != nil {
            focusedField = .lastName
            withAnimation { scrollProxy.scrollTo(CreateUserField.lastName, anchor: .center) }
            return
        }
        if emailError != nil {
            focusedField = .email
            withAnimation { scrollProxy.scrollTo(CreateUserField.email, anchor: .center) }
            return
        }
        if phoneError != nil {
            focusedField = .phone
            withAnimation { scrollProxy.scrollTo(CreateUserField.phone, anchor: .center) }
            return
        }
        if passwordError != nil {
            focusedField = .password
            withAnimation { scrollProxy.scrollTo(CreateUserField.password, anchor: .center) }
            return
        }
        if storeError != nil {
            // Cannot focus a picker, just return
            return
        }
        
        // Passed all validation
        isSubmitting = true
        statusMessage = nil
        
        let resolvedStoreID: UUID?
        if newRole == .boutiqueManager {
            resolvedStoreID = newStoreID
        } else if newRole == .inventoryController {
            // Find a valid store ID in the selected country to assign under the hood
            resolvedStoreID = authManager.supabaseStores.first(where: { $0.region == newCountry.rawValue })?.id
        } else {
            resolvedStoreID = nil
        }
        
        let request = NewUserRequest(
            username: newUsername,
            password: newPassword,
            displayName: "\(newFirstName.trimmingCharacters(in: .whitespacesAndNewlines)) \(newLastName.trimmingCharacters(in: .whitespacesAndNewlines))",
            phoneNumber: newPhoneNumber,
            role: newRole,
            storeID: resolvedStoreID
        )
        
        Task {
            do {
                try await authManager.createUser(request)
                await MainActor.run {
                    isSubmitting = false
                    showSuccessToast = true
                    statusMessage = "\(newRole.rawValue) created successfully."
                    
                    // Navigate back after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    showSuccessToast = false
                    statusMessage = error.localizedDescription
                }
            }
        }
    }
}
