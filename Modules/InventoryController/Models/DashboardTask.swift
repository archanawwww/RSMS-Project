import Foundation

struct DashboardTask: Identifiable, Codable, Hashable {

    let id: String
    let title: String
    let priority: Priority
    let taskType: String

    enum CodingKeys: String, CodingKey {

        case id
        case title
        case priority
        case taskType = "task_type"

    }

}
