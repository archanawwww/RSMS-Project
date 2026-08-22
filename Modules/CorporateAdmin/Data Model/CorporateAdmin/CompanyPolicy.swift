import Foundation

public struct CompanyPolicy: Codable, Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var content: String
    public var lastUpdated: Date
    
    public init(id: UUID = UUID(), title: String, content: String, lastUpdated: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.lastUpdated = lastUpdated
    }
}
