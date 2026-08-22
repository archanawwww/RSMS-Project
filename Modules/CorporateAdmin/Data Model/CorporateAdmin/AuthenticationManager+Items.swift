import Foundation

extension AuthenticationManager {

    // MARK: - UserDefaults Keys (for Audit Logs only now)

    private var auditLogsKey: String { "auth-management.audit-logs" }

    // MARK: - Load / Persist

    func loadCatalogData() {
        productMasterRecords = []
        productAuditLogs = loadAuditLogsFromStorage()
        itemCategories = []
    }

    private func loadAuditLogsFromStorage() -> [AuditLog] {
        guard let data = UserDefaults.standard.data(forKey: auditLogsKey),
              let decoded = try? JSONDecoder().decode([AuditLog].self, from: data) else {
            return []
        }
        return decoded
    }

    private func persistAuditLogs() {
        guard let data = try? JSONEncoder().encode(productAuditLogs) else { return }
        UserDefaults.standard.set(data, forKey: auditLogsKey)
    }

    // MARK: - Fetch Methods

    public func fetchCategories() async {
        do {
            let supabaseCategories = try await SupabaseAuthService.shared.fetchCategories()
            itemCategories = supabaseCategories.map {
                Category(id: $0.id, name: $0.name, description: $0.description, createdAt: Date())
            }
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }

    public func fetchCompanyPolicies() async {
        do {
            let supabasePolicies = try await SupabaseAuthService.shared.fetchCompanyPolicies()
            companyPolicies = supabasePolicies.map {
                CompanyPolicy(id: $0.id, title: $0.title, content: $0.content, lastUpdated: $0.lastUpdated)
            }
        } catch {
            print("Failed to fetch company policies: \(error)")
        }
    }
    
    public func fetchPricingRules() async {
        do {
            pricingRules = try await SupabaseAuthService.shared.fetchPricing()
        } catch {
            print("Failed to fetch pricing rules: \(error)")
        }
    }

    private func syncCategoriesFromProducts(_ products: [ProductMasterRecord]) {
        var categories = itemCategories
        let categoryNames = Set(products.map(\.category).filter { !$0.isEmpty })

        for name in categoryNames where !categories.contains(where: { $0.name == name }) {
            let newCategory = Category(name: name)
            categories.append(newCategory)
            Task {
                do {
                    try await SupabaseAuthService.shared.createCategory(
                        SupabaseCategory(id: newCategory.id, name: newCategory.name, description: newCategory.description)
                    )
                } catch {
                    print("Failed to create category: \(error)")
                }
            }
        }

        if categories != itemCategories {
            itemCategories = categories
        }
    }

    // MARK: - Category Methods

    public func addCategory(name: String, description: String?) {
        guard !itemCategories.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) else {
            return
        }
        let newCategory = Category(name: name, description: description)
        itemCategories.append(newCategory)
        Task {
            do {
                try await SupabaseAuthService.shared.createCategory(
                    SupabaseCategory(id: newCategory.id, name: newCategory.name, description: newCategory.description)
                )
            } catch {
                print("Failed to create category: \(error)")
            }
        }
    }

    public func updateCategory(_ category: Category) {
        guard let index = itemCategories.firstIndex(where: { $0.id == category.id }) else { return }
        itemCategories[index] = category
        Task {
            do {
                try await SupabaseAuthService.shared.updateCategory(
                    SupabaseCategory(id: category.id, name: category.name, description: category.description)
                )
            } catch {
                print("Failed to update category: \(error)")
            }
        }
    }

    public func deleteCategory(id: UUID) {
        itemCategories.removeAll { $0.id == id }
        Task {
            do {
                try await SupabaseAuthService.shared.deleteCategory(id: id)
            } catch {
                print("Failed to delete category: \(error)")
            }
        }
    }

    public func categoryName(for id: UUID?) -> String? {
        guard let id else { return nil }
        return itemCategories.first(where: { $0.id == id })?.name
    }

    // MARK: - Product Master Methods

    public func fetchProductMasterRecords() async {
        do {
            let products = try await SupabaseAuthService.shared.fetchProducts()
            productMasterRecords = products
            syncCategoriesFromProducts(products)
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    public func addProductMasterRecord(_ record: ProductMasterRecord) {
        Task {
            do {
                try await SupabaseAuthService.shared.createProduct(product: record)
                await fetchProductMasterRecords()
                logAuditAction(
                    action: .create,
                    tableName: "Product",
                    recordID: record.id,
                    previousValues: nil,
                    newValues: encodeToString(record)
                )
            } catch {
                print("Failed to create product: \(error)")
            }
        }
    }

    public func updateProductMasterRecord(_ record: ProductMasterRecord) {
        let oldRecord = productMasterRecords.first(where: { $0.id == record.id })
        Task {
            do {
                try await SupabaseAuthService.shared.updateProduct(product: record)
                await fetchProductMasterRecords()
                if let oldRecord {
                    logAuditAction(
                        action: .update,
                        tableName: "Product",
                        recordID: record.id,
                        previousValues: encodeToString(oldRecord),
                        newValues: encodeToString(record)
                    )
                }
            } catch {
                print("Failed to update product: \(error)")
            }
        }
    }

    public func deleteProductMasterRecord(id: UUID) {
        let oldRecord = productMasterRecords.first(where: { $0.id == id })
        Task {
            do {
                try await SupabaseAuthService.shared.deleteProduct(id: id)
                await fetchProductMasterRecords()
                if let oldRecord {
                    logAuditAction(
                        action: .delete,
                        tableName: "Product",
                        recordID: id,
                        previousValues: encodeToString(oldRecord),
                        newValues: nil
                    )
                }
            } catch {
                print("Failed to delete product: \(error)")
            }
        }
    }

    public func logAuditAction(
        action: AuditAction,
        tableName: String,
        recordID: UUID,
        previousValues: String?,
        newValues: String?
    ) {
        let modifierID = currentUser?.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let log = AuditLog(
            tableName: tableName,
            recordID: recordID,
            action: action,
            modifiedBy: modifierID,
            previousValues: previousValues,
            newValues: newValues
        )
        productAuditLogs.insert(log, at: 0)
        persistAuditLogs()
    }

    private func encodeToString<T: Encodable>(_ object: T) -> String? {
        guard let data = try? JSONEncoder().encode(object) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
