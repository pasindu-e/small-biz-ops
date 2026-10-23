import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @State private var filter = "All"
    @State private var showingAddOrder = false

    private let filters = ["All", "Pending", "Processing", "Delayed"]

    private var filteredOrders: [Order] {
        filter == "All" ? store.orders : store.orders.filter { $0.status.rawValue == filter }
    }

    private var headerOrderCount: Int { store.orders.count }
    private var headerTotalValue: Double { store.orders.reduce(0) { $0 + $1.total } }
    private var sectionCount: Int { filteredOrders.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                segmented
                    .padding(.top, 14)

                HStack {
                    Text(filter == "All" ? "Open orders" : filter).font(.appSectionTitle())
                    Spacer()
                    Text("\(sectionCount) orders").font(.appCaption()).foregroundColor(.appMuted)
                }
                .padding(.top, 22)
                .padding(.bottom, 10)

                ForEach(filteredOrders) { order in
                    OrderCard(order: order) {
                        router.go(.order(id: order.id))
                    }
                    .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .sheet(isPresented: $showingAddOrder) {
            AddOrderView().environmentObject(store)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Orders").font(.appHeroTitle())
                Text("\(headerOrderCount) open · \(headerTotalValue.asUSD()) total")
                    .font(.appCaption()).foregroundColor(.appMuted)
            }
            Spacer()
            Button {
                showingAddOrder = true
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.appNavy)
                    .clipShape(Circle())
            }
            .buttonStyle(.press)
        }
    }

    private var segmented: some View {
        HStack(spacing: 2) {
            ForEach(filters, id: \.self) { item in
                Button {
                    filter = item
                } label: {
                    Text(item)
                        .font(.system(size: 10, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 33)
                        .foregroundColor(filter == item ? .appNavy : .appMuted)
                        .background(filter == item ? Color.white : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .shadow(color: filter == item ? AppShadow.card : .clear, radius: 7, y: 2)
                }
                .buttonStyle(.press)
            }
        }
        .padding(3)
        .background(Color(hex: "E9EDF2"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    OrdersView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
