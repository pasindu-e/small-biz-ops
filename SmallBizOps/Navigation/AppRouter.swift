import SwiftUI

enum Screen: Hashable {
    case home
    case running
    case results
    case inventory
    case product(sku: String)
    case orders
    case order(id: String)
    case reorder(sku: String)
    case approved
    case tasks
    case activity
    case runDetail
    case settings
    case suppliers
}

/// Mirrors the React prototype's single `screen` state machine: each screen
/// fully replaces the visible content, and each back action targets a fixed
/// destination (not a generic pop), matching the original UX exactly.
@MainActor
final class AppRouter: ObservableObject {
    @Published var screen: Screen = .home

    var hasBottomNav: Bool {
        switch screen {
        case .home, .inventory, .orders, .activity: return true
        default: return false
        }
    }

    var isDarkScreen: Bool {
        if case .running = screen { return true }
        return false
    }

    func go(_ screen: Screen) {
        withAnimation(.easeInOut(duration: 0.22)) {
            self.screen = screen
        }
    }
}
