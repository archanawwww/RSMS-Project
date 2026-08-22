import Foundation

struct StoreRequest: Identifiable, Codable, Hashable {

    let id: String
    let requestType: RequestType
    let storeName: String
    let sku: String
    let productName: String
    let quantityRequested: Int
    let priority: Priority
    let managerRemark: String?
    var status: RequestStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case requestType = "request_type"
        case storeName = "store_name"
        case sku
        case productName = "product_name"
        case quantityRequested = "quantity_requested"
        case priority
        case managerRemark = "manager_remark"
        case status
        case createdAt = "created_at"
    }
}


enum RequestType: String, Codable, CaseIterable {
    case refill = "Refill"
    case transfer = "Transfer"
    case inTransit = "In Transit"
}



enum RequestStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case fulfilled = "fulfilled"

    static var requestFilters: [RequestStatus] {
        [.pending, .fulfilled, .rejected]
    }

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .fulfilled: return "Approved"
        }
    }

    var matchesApprovedFilter: Bool {
        self == .approved || self == .fulfilled
    }
}


enum Priority: String, Codable, CaseIterable {
    case normal = "normal"
    case urgent = "urgent"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        if let matched = Priority(rawValue: rawString.lowercased()) {
            self = matched
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot initialize Priority from invalid String value \(rawString)"
            )
        }
    }

    var displayName: String {
        switch self {
        case .normal:
            return "Normal"
        case .urgent:
            return "Urgent"
        }
    }
}
