import Foundation

struct Shipment: Identifiable, Codable, Hashable {
    let id: String
    let vendorRequestID: String
    let vendorName: String
    var status: ShipmentStatus
    let expectedDate: Date
    
    // Extended fields for the new UI
    var origin: String?
    var destination: String?
    var itemsCount: Int?
    var asnNumber: String?
    var carrier: String?
    var trackingNumber: String?
    
    var completedDate: Date?
    var returnedDate: Date?
    var cancelledDate: Date?
    var exceptionIssue: String?
    
    var arrivedAt: Date?
    var receivedAt: Date?
    var dispatchedAt: Date?
    var inTransitAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case vendorRequestID = "vendor_request_id"
        case vendorName = "vendor_name"
        case status
        case expectedDate = "expected_date"
        
        case origin
        case destination
        case itemsCount = "items_count"
        case asnNumber = "asn_number"
        case carrier
        case trackingNumber = "tracking_number"
        case completedDate = "completed_date"
        case returnedDate = "returned_date"
        case cancelledDate = "cancelled_date"
        case exceptionIssue = "exception_issue"
        
        case arrivedAt = "arrived_at"
        case receivedAt = "received_at"
        case dispatchedAt = "dispatched_at"
        case inTransitAt = "in_transit_at"
    }
}



enum ShipmentStatus: String, Codable, CaseIterable {
    // Legacy support cases
    case created = "created"
    case approved = "approved"
    case dispatched = "dispatched"
    case received = "received"
    
    // New UX cases
    case inTransit = "inTransit"
    case awaitingReceipt = "awaitingReceipt"
    case processing = "processing"
    case exception = "exception"
    case completed = "completed"
    case returned = "returned"
    case cancelled = "cancelled"

    var title: String {
        switch self {
        case .created: return "Created"
        case .approved: return "Approved"
        case .dispatched: return "Dispatched"
        case .received: return "Received"
        
        case .inTransit: return "In Transit"
        case .awaitingReceipt: return "Awaiting Receipt"
        case .processing: return "Processing"
        case .exception: return "Exception"
        case .completed: return "Completed"
        case .returned: return "Returned"
        case .cancelled: return "Cancelled"
        }
    }
}
