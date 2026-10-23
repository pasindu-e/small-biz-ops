import SwiftUI

struct ReorderView: View {
    let sku: String
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @State private var quantity = 20

    private var product: Product? { store.product(sku: sku) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Reorder proposal", onBack: { router.go(.results) })

                if let product {
                    proposalHero(product)
                    stockEquation(product)
                        .padding(.top, 4)

                    Text("Suggested quantity").font(.appSectionTitle()).padding(.top, 22).padding(.bottom, 10)
                    quantityControl

                    proposalDetails(product)
                        .padding(.top, 12)

                    explainCard(product)
                        .padding(.top, 12)

                    approvalNotice
                        .padding(.top, 12)

                    let estimatedTotal = Double(quantity) * product.unitCost
                    let estimatedTotalString = estimatedTotal.asUSD()
                    PrimaryButton(title: "Approve Reorder · \(estimatedTotalString)") {
                        store.approveReorder(product: product, quantity: quantity)
                        router.go(.approved)
                    }
                    .padding(.top, 16)

                    SecondaryButton(title: "Edit Proposal Details") {}
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .onAppear {
            if let product { quantity = max(product.minimum - product.stock, product.minimum) }
        }
    }

    private func proposalHero(_ product: Product) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: "EEE5DA"), Color(hex: "DFD0BE")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 68, height: 68)
                Image(systemName: "shippingbox.fill").font(.system(size: 28)).foregroundColor(Color(hex: "796044"))
            }
            VStack(alignment: .leading, spacing: 6) {
                StatusBadge(text: product.status.rawValue, tone: product.status.tone)
                Text(product.name).font(.system(size: 17, weight: .bold))
                Text("\(product.sku) · \(product.supplier)").font(.appCaption()).foregroundColor(.appMuted)
            }
        }
        .padding(.vertical, 12)
    }

    private func stockEquation(_ product: Product) -> some View {
        HStack(spacing: 4) {
            equationItem(label: "Current", value: "\(product.stock)")
            Image(systemName: "arrow.right").foregroundColor(.appLightMuted).font(.system(size: 11))
            equationItem(label: "Minimum", value: "\(product.minimum)")
            Image(systemName: "arrow.right").foregroundColor(.appLightMuted).font(.system(size: 11))
            VStack(spacing: 4) {
                Text("After reorder").font(.system(size: 8)).foregroundColor(.appMuted)
                Text("\(quantity + product.stock)").font(.system(size: 18, weight: .bold)).foregroundColor(Color(hex: "087968"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color(hex: "E4F7F3"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .appCard(padding: 0)
    }

    private func equationItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.system(size: 8)).foregroundColor(.appMuted)
            Text(value).font(.system(size: 18, weight: .bold))
        }
        .frame(maxWidth: .infinity)
    }

    private var quantityControl: some View {
        HStack(spacing: 9) {
            Button {
                quantity = max(1, quantity - 1)
            } label: {
                Image(systemName: "minus")
                    .foregroundColor(.appSlate)
                    .frame(width: 48, height: 48)
                    .background(Color(hex: "EEF1F5"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.press)

            VStack(spacing: 2) {
                Text("\(quantity)").font(.system(size: 25, weight: .bold))
                Text("units").font(.system(size: 9)).foregroundColor(.appMuted)
            }
            .frame(maxWidth: .infinity)

            Button {
                quantity += 1
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.appSlate)
                    .frame(width: 48, height: 48)
                    .background(Color(hex: "EEF1F5"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.press)
        }
        .padding(9)
        .frame(height: 72)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous).stroke(Color.appLine, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private func proposalDetails(_ product: Product) -> some View {
        VStack(spacing: 0) {
            detailLine(label: "Supplier", value: product.supplier)
            Divider().background(Color.appLine)
            detailLine(label: "Unit cost", value: product.unitCost, isCurrency: true)
            Divider().background(Color.appLine)
            HStack {
                Text("Estimated total").font(.system(size: 14))
                Spacer()
                Text((Double(quantity) * product.unitCost).asUSD()).font(.system(size: 14, weight: .bold))
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
        }
        .appCard(padding: 0)
    }

    private func detailLine(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.appMuted)
            Spacer()
            Text(value).font(.system(size: 11, weight: .semibold))
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
    }

    private func detailLine(label: String, value: Double, isCurrency: Bool) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.appMuted)
            Spacer()
            Text((value).asUSD()).font(.system(size: 11, weight: .semibold))
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
    }

    private func explainCard(_ product: Product) -> some View {
        let days = product.averageDailyUsage > 0 ? Int((Double(quantity) / product.averageDailyUsage).rounded()) : 0
        return HStack(alignment: .top, spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Color(hex: "EAECFF")).frame(width: 34, height: 34)
                Image(systemName: "sparkles").font(.system(size: 15)).foregroundColor(Color(hex: "5D64C7"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("WHY THIS QUANTITY?").font(.system(size: 10, weight: .heavy)).tracking(0.7).foregroundColor(Color(hex: "626CC3"))
                Text("Based on an average of \(product.averageDailyUsage, specifier: "%.1f") units used per day, \(quantity) units provides about \(days) days of coverage while keeping stock above your minimum.")
                    .font(.appCaption()).foregroundColor(.appMuted).lineSpacing(2)
            }
        }
        .padding(13)
        .appCard(padding: 0)
    }

    private var approvalNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.fill").font(.system(size: 17)).foregroundColor(Color(hex: "365E98"))
            VStack(alignment: .leading, spacing: 3) {
                Text("You're in control").font(.system(size: 11, weight: .bold))
                Text("No order is placed until you review and approve it.").font(.system(size: 10)).lineSpacing(2)
            }
            .foregroundColor(Color(hex: "365E98"))
        }
        .padding(12)
        .background(Color.appIce)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

#Preview {
    ReorderView(sku: "COF-001").environmentObject(AppRouter()).environmentObject(MockDataStore())
}
