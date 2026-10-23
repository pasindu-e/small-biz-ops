import SwiftUI

struct OrderDetailView: View {
    let orderId: String
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore

    private var order: Order? { store.order(id: orderId) }
    private var created: Bool { store.createdFollowUpTaskForOrder.contains(orderId) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let order {
                    BackHeader(title: order.id, onBack: { router.go(.orders) }) {
                        StatusBadge(text: order.status.rawValue, tone: order.status.tone)
                    }

                    if created {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark").foregroundColor(.white)
                            Text("Follow-up task added for today").foregroundColor(.white)
                        }
                        .font(.system(size: 11))
                        .padding(11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appSlate)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.bottom, 10)
                    }

                    customerCard(order)

                    Text("Order summary").font(.appSectionTitle()).padding(.top, 22).padding(.bottom, 10)
                    summaryCard(order)

                    Text("Status timeline").font(.appSectionTitle()).padding(.top, 22).padding(.bottom, 10)
                    timelineCard(order)

                    if order.status == .delayed {
                        suggestionCard
                            .padding(.top, 12)
                    }

                    PrimaryButton(
                        title: created ? "Task Created" : "Create Follow-up Task",
                        systemImage: "checkmark",
                        style: created ? .disabledSuccess : .dark
                    ) {
                        store.createFollowUpTask(for: order)
                    }
                    .padding(.top, 16)
                } else {
                    Text("Order not found").foregroundColor(.appMuted).padding(.top, 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .animation(.easeInOut, value: created)
    }

    private func customerCard(_ order: Order) -> some View {
        HStack(spacing: 11) {
            Circle()
                .fill(Color.appIce)
                .frame(width: 40, height: 40)
                .overlay(Text(initials(order.customer)).font(.system(size: 12, weight: .bold)).foregroundColor(.appBlue))
            VStack(alignment: .leading, spacing: 3) {
                Text(order.customer).font(.appRowTitle())
                Text("\(order.email) · \(order.phone)").font(.appCaption()).foregroundColor(.appMuted)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(.appMuted)
        }
        .padding(13)
        .appCard(padding: 0)
    }

    private func summaryCard(_ order: Order) -> some View {
        VStack(spacing: 0) {
            ForEach(order.lineItems) { item in
                HStack {
                    Text(item.title).font(.system(size: 11)).foregroundColor(.appMuted)
                    Spacer()
                    Text((item.amount).asUSD()).font(.system(size: 11, weight: .semibold))
                }
                .padding(.vertical, 12).padding(.horizontal, 14)
                Divider().background(Color.appLine)
            }
            HStack {
                Text("Shipping").font(.system(size: 11)).foregroundColor(.appMuted)
                Spacer()
                Text((order.shipping).asUSD()).font(.system(size: 11, weight: .semibold))
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
            .background(Color(hex: "FAFBFC"))
            HStack {
                Text("Total").font(.system(size: 14))
                Spacer()
                Text((order.total).asUSD()).font(.system(size: 14, weight: .bold))
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
        }
        .appCard(padding: 0)
    }

    private func timelineCard(_ order: Order) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(order.timeline.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 11) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(step.complete ? Color.appTeal : Color.badgeDangerBG)
                                .overlay(step.complete ? nil : Circle().stroke(Color.appDanger, lineWidth: 2))
                                .frame(width: 20, height: 20)
                            if step.complete {
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.appNavy)
                            }
                        }
                        .padding(.top, 2)
                        if index < order.timeline.count - 1 {
                            Rectangle().fill(Color.appTeal).frame(width: 1).frame(maxHeight: .infinity)
                        }
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(step.title).font(.appRowTitle())
                        Text(step.subtitle).font(.appCaption()).foregroundColor(.appMuted)
                    }
                    Spacer()
                }
                .frame(minHeight: 55)
            }
        }
        .padding(.vertical, 9).padding(.horizontal, 14)
        .appCard(padding: 0)
    }

    private var suggestionCard: some View {
        HStack(alignment: .top, spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Color(hex: "EAECFF")).frame(width: 34, height: 34)
                Image(systemName: "sparkles").font(.system(size: 15)).foregroundColor(Color(hex: "5D64C7"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("AGENT SUGGESTION").font(.system(size: 10, weight: .heavy)).tracking(0.7).foregroundColor(Color(hex: "626CC3"))
                Text("Follow up with Maya today").font(.appRowTitle())
                Text("The promised delivery date passed 2 days ago. A proactive update can protect the customer relationship.")
                    .font(.appCaption()).foregroundColor(.appMuted).lineSpacing(2)
            }
        }
        .padding(13)
        .background(Color(hex: "F3F3FF"))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous).stroke(Color(hex: "E3E3FF"), lineWidth: 1))
    }

    private func initials(_ name: String) -> String {
        name.split(separator: " ").compactMap { $0.first }.map(String.init).joined()
    }
}

#Preview {
    OrderDetailView(orderId: "#ORD-1048").environmentObject(AppRouter()).environmentObject(MockDataStore())
}
