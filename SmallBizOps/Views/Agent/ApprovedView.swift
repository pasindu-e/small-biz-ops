import SwiftUI

struct ApprovedView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(Color(hex: "EDF9F7")).frame(width: 100, height: 100)
                    Circle().fill(Color(hex: "D9F7F1")).frame(width: 76, height: 76)
                    Image(systemName: "checkmark").font(.system(size: 34, weight: .bold)).foregroundColor(Color(hex: "067766"))
                }
                .padding(.bottom, 22)

                Text("Reorder approved").font(.system(size: 26, weight: .bold))
                    .padding(.bottom, 9)

                if let approval = store.lastReorderApproval {
                    Text("\(approval.quantity) units of \(approval.product) have been added to your reorder queue.")
                        .font(.system(size: 13))
                        .foregroundColor(.appMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: 300)
                        .padding(.bottom, 22)

                    confirmationCard(approval)
                        .padding(.bottom, 12)
                }

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle").font(.system(size: 17)).foregroundColor(Color(hex: "365E98"))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Next step").font(.system(size: 11, weight: .bold))
                        Text("The purchase order is ready to send. No funds have been charged.")
                            .font(.system(size: 10)).lineSpacing(2)
                    }
                    .foregroundColor(Color(hex: "365E98"))
                }
                .padding(12)
                .background(Color.appIce)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .padding(.bottom, 16)

                PrimaryButton(title: "Return to Home") {
                    router.go(.home)
                }
                SecondaryButton(title: "View Activity") {
                    router.go(.activity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 95)
        }
        .background(Color.appOffWhite)
    }

    private func confirmationCard(_ approval: (product: String, quantity: Int, total: Double)) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Reference").font(.system(size: 11)).foregroundColor(.appMuted)
                Spacer()
                Text("PO-2091").font(.system(size: 11, weight: .semibold))
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
            Divider().background(Color.appLine)
            HStack {
                Text("Estimated total").font(.system(size: 11)).foregroundColor(.appMuted)
                Spacer()
                Text((approval.total).asUSD()).font(.system(size: 11, weight: .semibold))
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
            Divider().background(Color.appLine)
            HStack {
                Text("Status").font(.system(size: 11)).foregroundColor(.appMuted)
                Spacer()
                StatusBadge(text: "Approved", tone: .success)
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
        }
        .appCard(padding: 0)
    }
}

#Preview {
    ApprovedView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
