import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxHeight: .infinity)

            if router.hasBottomNav {
                BottomNav(current: router.screen) { router.go($0) }
            }
        }
        .background(router.isDarkScreen ? Color.appNavy : Color.appOffWhite)
        .preferredColorScheme(.light)
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var content: some View {
        switch router.screen {
        case .home:
            HomeView()
        case .running:
            AgentRunningView()
        case .results:
            AgentResultsView()
        case .inventory:
            InventoryView()
        case .product(let sku):
            ProductDetailView(sku: sku)
        case .orders:
            OrdersView()
        case .order(let id):
            OrderDetailView(orderId: id)
        case .reorder(let sku):
            ReorderView(sku: sku)
        case .approved:
            ApprovedView()
        case .tasks:
            TasksView()
        case .activity:
            ActivityView()
        case .runDetail:
            RunDetailView()
        case .settings:
            SettingsView()
        case .suppliers:
            SuppliersView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppRouter())
        .environmentObject(MockDataStore())
}
