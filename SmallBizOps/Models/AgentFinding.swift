import Foundation

enum FindingSeverity: String, Equatable {
    case highPriority = "HIGH PRIORITY"
    case medium = "MEDIUM"

    var tone: BadgeTone {
        switch self {
        case .highPriority: return .danger
        case .medium: return .warning
        }
    }
}

struct AgentFinding: Identifiable {
    let id = UUID()
    let severity: FindingSeverity
    let title: String
    let factLabel: String?
    let factValue: String?
    let copy: String?
    let suggestion: String?
    let destination: Screen
}

struct TraceLine: Identifiable {
    let id = UUID()
    let tone: BadgeTone
    let label: String
    let detail: String
}
