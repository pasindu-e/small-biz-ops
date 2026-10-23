import SwiftUI

struct BottomNav: View {
    let current: Screen
    let go: (Screen) -> Void

    private let items: [(icon: String, label: String, screen: Screen)] = [
        ("house", "Home", .home),
        ("shippingbox", "Inventory", .inventory),
        ("doc.text", "Orders", .orders),
        ("waveform.path.ecg", "Activity", .activity),
    ]

    private func isActive(_ screen: Screen) -> Bool {
        switch (current, screen) {
        case (.home, .home), (.inventory, .inventory), (.orders, .orders), (.activity, .activity):
            return true
        default:
            return false
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                let active = isActive(item.screen)
                Button {
                    go(item.screen)
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: item.icon)
                            .font(.system(size: 20))
                        Text(item.label)
                            .font(.system(size: 9, weight: .semibold))
                        Circle()
                            .fill(Color.appTeal)
                            .frame(width: 4, height: 4)
                            .opacity(active ? 1 : 0)
                    }
                    .foregroundColor(active ? .appNavy : Color(hex: "8B96A6"))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.press)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
        .overlay(Rectangle().fill(Color.appLine).frame(height: 1), alignment: .top)
    }
}
