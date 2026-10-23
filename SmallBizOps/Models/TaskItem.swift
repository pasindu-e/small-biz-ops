import Foundation

enum TaskPriority: String, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var tone: BadgeTone {
        switch self {
        case .high: return .danger
        case .medium: return .warning
        case .low: return .neutral
        }
    }
}

struct TaskItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var relatedTo: String
    var time: String
    var priority: TaskPriority
    var isCompleted: Bool = false
}
