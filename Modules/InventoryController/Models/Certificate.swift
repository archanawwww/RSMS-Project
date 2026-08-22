import Foundation

struct Certificate: Identifiable, Codable, Hashable {
    let id: UUID
    let serialId: UUID
    let certificateNumber: String
    let certificateUrl: String?
    let issuedAt: Date
    var status: String // "Verified", "Missing", "Pending Verification", "Invalid"
    
    enum CodingKeys: String, CodingKey {
        case id
        case serialId = "serial_id"
        case certificateNumber = "certificate_number"
        case certificateUrl = "certificate_url"
        case issuedAt = "issued_at"
        case status
    }
}
