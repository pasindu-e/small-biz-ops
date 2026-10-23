import Foundation

enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case processing = "Processing"
    case delayed = "Delayed"

    var tone: BadgeTone {
        switch self {
        case .pending: return .warning
        case .processing: return .info
        case .delayed: return .danger
        }
    }
}

struct OrderLineItem: Identifiable, Codable {
    let id = UUID()
    let title: String
    let amount: Double
}

struct OrderStatusStep: Identifiable, Codable {
    let id = UUID()
    let title: String
    let subtitle: String
    let complete: Bool
}

struct Order: Identifiable, Hashable, Codable {
    var id: String // e.g. #ORD-1048
    let customer: String
    let email: String
    let phone: String
    let total: Double
    let status: OrderStatus
    let time: String
    let itemsLabel: String
    let lineItems: [OrderLineItem]
    let shipping: Double
    let timeline: [OrderStatusStep]

    static func == (lhs: Order, rhs: Order) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
