import Foundation

enum StockStatus: String, Codable {
    case lowStock = "Low stock"
    case inStock = "In stock"

    var tone: BadgeTone {
        switch self {
        case .lowStock: return .danger
        case .inStock: return .success
        }
    }
}

struct Product: Identifiable, Hashable, Codable {
    var id: String { sku }
    var name: String
    var sku: String
    var stock: Int
    var minimum: Int
    var status: StockStatus
    var category: String
    var supplier: String
    var unitCost: Double
    var averageDailyUsage: Double

    static func == (lhs: Product, rhs: Product) -> Bool { lhs.sku == rhs.sku }
    func hash(into hasher: inout Hasher) { hasher.combine(sku) }
}
