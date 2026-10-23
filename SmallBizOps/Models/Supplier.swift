import Foundation
import CoreLocation

struct Supplier: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var category: String
    var address: String
    var city: String
    var phone: String
    var email: String
    var leadTimeDays: Int
    var productsSupplied: [String]
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Supplier, rhs: Supplier) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
