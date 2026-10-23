import Foundation

struct Business: Codable, Equatable {
    var ownerName: String
    var businessName: String
    var role: String

    var ownerInitials: String {
        let initials = ownerName.split(separator: " ").compactMap { $0.first }.map(String.init).joined()
        return initials.isEmpty ? "?" : initials.uppercased()
    }

    static let placeholder = Business(ownerName: "Your Name", businessName: "Your Business", role: "Owner")

    static var todayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date()).uppercased()
    }

    static var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
}

struct SettingsRow: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let subtitle: String
}

struct SettingsGroup: Identifiable {
    let id = UUID()
    let title: String
    let rows: [SettingsRow]
}
