import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                topRow
                kpiGrid
                    .padding(.top, 16)
                agentBrief
                    .padding(.top, 16)

                sectionRow(title: "Needs attention", trailing: "\(store.needsAttentionCount) items")
                attentionCards
                    .padding(.top, 8)

                sectionRow(title: "Today's tasks", actionTitle: "View all") {
                    router.go(.tasks)
                }
                todayTaskPreview
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .alert("Data Sync Issue", isPresented: Binding(
            get: { store.diagnosticMessage != nil },
            set: { if !$0 { store.diagnosticMessage = nil } }
        )) {
            Button("OK") { store.diagnosticMessage = nil }
        } message: {
            Text(store.diagnosticMessage ?? "")
        }
    }

    private var lastPreparedLabel: String {
        guard let run = store.todayRun ?? store.yesterdayRun else { return "Not prepared yet" }
        return "Last prepared \(run.dateLabel.lowercased()) · \(run.timeLabel)"
    }

    private var firstName: String {
        store.business.ownerName.split(separator: " ").first.map(String.init) ?? store.business.ownerName
    }

    private var topRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                Text(Business.todayLabel).eyebrowStyle()
                Text("\(Business.greeting), \(firstName)").font(.appHeroTitle()).foregroundColor(.appNavy)
                Text(store.business.businessName).font(.system(size: 14)).foregroundColor(.appMuted)
            }
            Spacer()
            Button {
                router.go(.settings)
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(LinearGradient(colors: [.appSlate, Color(hex: "34476C")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                        .overlay(Text(store.business.ownerInitials).font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                    Circle().fill(Color.appTeal).frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.appOffWhite, lineWidth: 2))
                }
            }
            .buttonStyle(.press)
        }
        .padding(.bottom, 24)
    }

    private var kpiGrid: some View {
        HStack(spacing: 9) {
            KPICard(icon: "shippingbox", value: "\(store.products.count)", label: "Products", tint: .blue)
            KPICard(icon: "doc.text", value: "\(store.openOrdersCount)", label: "Open orders", tint: .indigo)
            KPICard(icon: "exclamationmark.triangle", value: "\(store.needsAttentionCount)", label: "Need attention", tint: .coral)
        }
    }

    private var agentBrief: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(RadialGradient(colors: [Color.appIndigo.opacity(0.45), .clear], center: .center, startRadius: 0, endRadius: 90))
                .frame(width: 180, height: 180)
                .offset(x: 60, y: -100)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(LinearGradient(colors: [.appIndigo, .appTeal], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 34, height: 34)
                        Image(systemName: "sparkles").foregroundColor(.appNavy)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OPERATIONS AGENT").font(.appEyebrow()).foregroundColor(Color(hex: "D5DCFF"))
                        Text(lastPreparedLabel).font(.system(size: 11)).foregroundColor(Color(hex: "93A1BB"))
                    }
                }

                Text("Start the day with a clear plan.")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("I'll review inventory and orders, identify what needs attention, and prepare actions for your approval.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "BBC5D7"))
                    .lineSpacing(4)
                    .padding(.top, 8)
                    .padding(.bottom, 17)

                PrimaryButton(title: "Prepare Today", trailingArrow: true, style: .light) {
                    router.go(.running)
                }

                HStack(spacing: 5) {
                    Image(systemName: "shield").font(.system(size: 11))
                    Text("Analysis happens on this device").font(.system(size: 10))
                }
                .foregroundColor(Color(hex: "93A1BB"))
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color(hex: "14213C"), Color(hex: "1D2D53"), Color(hex: "243B5A")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(color: AppShadow.elevated, radius: 20, x: 0, y: 14)
    }

    private func sectionRow(title: String, trailing: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title).font(.appSectionTitle())
            Spacer()
            if let trailing {
                Text(trailing).font(.appCaption()).foregroundColor(.appMuted)
            }
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle).font(.system(size: 12, weight: .bold)).foregroundColor(.appBlue)
                }
                .buttonStyle(.press)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 10)
    }

    private var lowStockProducts: [Product] {
        store.products.filter { $0.status == .lowStock }.sorted { $0.stock < $1.stock }
    }

    private var delayedOrders: [Order] {
        store.orders.filter { $0.status == .delayed }
    }

    @ViewBuilder
    private var attentionCards: some View {
        if lowStockProducts.isEmpty && delayedOrders.isEmpty {
            emptyCard(icon: "checkmark.circle", text: "Nothing needs attention right now.")
        } else {
            VStack(spacing: 8) {
                ForEach(lowStockProducts.prefix(2)) { product in
                    Button {
                        router.go(.product(sku: product.sku))
                    } label: {
                        HStack(spacing: 11) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.appDanger)
                                .frame(width: 36, height: 36)
                                .background(Color.kpiCoralBG)
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(product.name).font(.appRowTitle()).foregroundColor(.primary)
                                Text("\(product.stock) units left · Below minimum of \(product.minimum)").font(.appCaption()).foregroundColor(.appMuted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(.appMuted)
                        }
                        .padding(12)
                    }
                    .buttonStyle(.press)
                    .appCard(padding: 0)
                }

                ForEach(delayedOrders.prefix(2)) { order in
                    Button {
                        router.go(.order(id: order.id))
                    } label: {
                        HStack(spacing: 11) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.appWarning)
                                .frame(width: 36, height: 36)
                                .background(Color(hex: "FFF4DB"))
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Order \(order.id) delayed").font(.appRowTitle()).foregroundColor(.primary)
                                Text("\(order.time)").font(.appCaption()).foregroundColor(.appMuted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(.appMuted)
                        }
                        .padding(12)
                    }
                    .buttonStyle(.press)
                    .appCard(padding: 0)
                }
            }
        }
    }

    private var nextTask: TaskItem? {
        store.tasks.filter { !$0.isCompleted }.first { $0.priority == .high }
            ?? store.tasks.first { !$0.isCompleted }
    }

    @ViewBuilder
    private var todayTaskPreview: some View {
        if let task = nextTask {
            Button {
                router.go(.tasks)
            } label: {
                HStack(spacing: 11) {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color(hex: "C6CFDB"), lineWidth: 1.5)
                        .frame(width: 21, height: 21)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title).font(.appRowTitle()).foregroundColor(.primary)
                        Text("\(task.priority.rawValue) priority · \(task.time)").font(.appCaption()).foregroundColor(.appMuted)
                    }
                    Spacer()
                    StatusBadge(text: task.priority.rawValue, tone: task.priority.tone)
                }
                .padding(12)
            }
            .buttonStyle(.press)
            .appCard(padding: 0)
        } else {
            emptyCard(icon: "checkmark.circle", text: "No tasks for today.")
        }
    }

    private func emptyCard(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(.appMuted)
            Text(text).font(.appCaption()).foregroundColor(.appMuted)
            Spacer()
        }
        .padding(12)
        .appCard(padding: 0)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
        .environmentObject(MockDataStore())
}
