import Foundation

enum VendorRequestStatus: String, Codable, CaseIterable {
    case created = "created"
    case approved = "approved"
    case rejected = "rejected"
    case dispatched = "dispatched"
    case inTransit = "inTransit"
    case received = "received"
    case completed = "completed"
    case cancelled = "cancelled"

    var title: String {
        switch self {
        case .created: return "Created"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .dispatched: return "Dispatched"
        case .inTransit: return "In Transit"
        case .received: return "Received"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}
