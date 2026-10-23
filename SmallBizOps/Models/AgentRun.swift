import Foundation

struct ExecutionStep: Identifiable, Codable {
    let id = UUID()
    let kind: String // PLAN, TOOL CALL, RESULT, RECOMMEND
    let title: String
    let copy: String
}

enum RunReviewState: String, Codable {
    case approved = "1 approved"
    case reviewed = "Reviewed"
}

struct AgentRun: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let dateLabel: String // "Today", "Yesterday"
    let timeLabel: String // "8:42 AM"
    let duration: String  // "18 sec"
    let findingsCount: Int
    let tasksCount: Int
    let toolCallsCount: Int
    let reviewState: RunReviewState
    let executionTrace: [ExecutionStep]
    let createdAt: Date
}

struct ActivityEvent: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let subtitle: String
    let time: String
    let isApproved: Bool
    let createdAt: Date
}
