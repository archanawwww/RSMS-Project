import Foundation

public struct Category: Codable, Equatable, Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var createdAt: Date

    public init(id: UUID = UUID(), name: String, description: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
    }
}

public struct AuthenticitySettings: Codable, Equatable, Hashable {
    public var requiresCertificate: Bool
    public var notes: String?

    public init(requiresCertificate: Bool = false, notes: String? = nil) {
        self.requiresCertificate = requiresCertificate
        self.notes = notes
    }
}

/// Maps to the Supabase `Product` table.
public struct ProductMasterRecord: Codable, Equatable, Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var category: String
    public var sku: String
    public var authenticitySettings: AuthenticitySettings
    public var createdAt: Date
    public var updatedAt: Date

    public var brand: String
    public var price: Double
    public var costPrice: Double
    public var tax: Double
    public var barcode: String
    public var isActive: Bool
    public var isArchived: Bool
    public var imageURL: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case sku
        case name
        case brand
        case category
        case barcode
        case price = "basePrice"
        case costPrice
        case tax
        case isActive
        case isArchived
        case imageURL = "image_url"
        case requiresCertificate
        case authenticityNotes
        case createdAt
        case updatedAt
    }

    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        category: String = "",
        sku: String,
        authenticitySettings: AuthenticitySettings = AuthenticitySettings(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        brand: String = "",
        price: Double = 0.0,
        costPrice: Double = 0.0,
        tax: Double = 18.0,
        barcode: String = "",
        isActive: Bool = true,
        isArchived: Bool = false,
        imageURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.sku = sku
        self.authenticitySettings = authenticitySettings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.brand = brand
        self.price = price
        self.costPrice = costPrice
        self.tax = tax
        self.barcode = barcode
        self.isActive = isActive
        self.isArchived = isArchived
        self.imageURL = imageURL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        sku = try container.decode(String.self, forKey: .sku)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decodeIfPresent(String.self, forKey: .brand) ?? ""
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        barcode = try container.decodeIfPresent(String.self, forKey: .barcode) ?? ""
        price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0
        costPrice = try container.decodeIfPresent(Double.self, forKey: .costPrice) ?? 0
        tax = try container.decodeIfPresent(Double.self, forKey: .tax) ?? 18
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        
        let requiresCertificate = try container.decodeIfPresent(Bool.self, forKey: .requiresCertificate) ?? false
        let authenticityNotes = try container.decodeIfPresent(String.self, forKey: .authenticityNotes)
        
        authenticitySettings = AuthenticitySettings(requiresCertificate: requiresCertificate, notes: authenticityNotes)
        description = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sku, forKey: .sku)
        try container.encode(name, forKey: .name)
        try container.encode(brand, forKey: .brand)
        try container.encode(category, forKey: .category)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(price, forKey: .price)
        try container.encode(costPrice, forKey: .costPrice)
        try container.encode(tax, forKey: .tax)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(isArchived, forKey: .isArchived)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(authenticitySettings.requiresCertificate, forKey: .requiresCertificate)
        try container.encodeIfPresent(authenticitySettings.notes, forKey: .authenticityNotes)
    }
}

public enum AuditAction: String, Codable {
    case create = "CREATE"
    case update = "UPDATE"
    case delete = "DELETE"
}

public struct AuditLog: Codable, Identifiable {
    public let id: UUID
    public let tableName: String
    public let recordID: UUID
    public let action: AuditAction
    public let modifiedBy: UUID
    public let modifiedAt: Date
    public let previousValues: String?
    public let newValues: String?

    public init(
        id: UUID = UUID(),
        tableName: String,
        recordID: UUID,
        action: AuditAction,
        modifiedBy: UUID,
        modifiedAt: Date = Date(),
        previousValues: String? = nil,
        newValues: String? = nil
    ) {
        self.id = id
        self.tableName = tableName
        self.recordID = recordID
        self.action = action
        self.modifiedBy = modifiedBy
        self.modifiedAt = modifiedAt
        self.previousValues = previousValues
        self.newValues = newValues
    }
}
