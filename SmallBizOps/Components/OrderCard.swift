import SwiftUI

struct OrderCard: View {
    let order: Order
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.id).font(.appCaption()).foregroundColor(.appMuted)
                        Text(order.customer).font(.appRowTitle()).foregroundColor(.primary)
                    }
                    Spacer()
                    Text((order.total).asUSD())
                        .font(.system(size: 16, weight: .bold))
                }
                Divider().background(Color.appLine)
                HStack(spacing: 7) {
                    StatusBadge(text: order.status.rawValue, tone: order.status.tone)
                    Text(order.itemsLabel).font(.system(size: 9)).foregroundColor(.appMuted)
                    Text("·").font(.system(size: 9)).foregroundColor(.appMuted)
                    Text(order.time).font(.system(size: 9)).foregroundColor(.appMuted)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.appMuted)
                }
            }
            .padding(15)
        }
        .buttonStyle(.press)
        .appCard(padding: 0)
    }
}
