import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @EnvironmentObject var auth: AuthStore
    @State private var showingBusinessProfile = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Settings", onBack: { router.go(.home) })

                profileCard
                    .padding(.top, 8)

                ForEach(MockData.settingsGroups) { group in
                    Text(group.title)
                        .font(.system(size: 10, weight: .heavy)).tracking(1.1)
                        .foregroundColor(.appLightMuted)
                        .padding(.top, 22)
                        .padding(.bottom, 8)

                    settingsCard(group)
                }

                Button {
                    router.go(.home)
                    auth.signOut()
                } label: {
                    Text("Log Out")
                        .font(.appButton())
                        .foregroundColor(.appDanger)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.appLine, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.press)
                .padding(.top, 22)

                HStack(spacing: 5) {
                    Image(systemName: "shield").font(.system(size: 13))
                    Text("Built for privacy. Designed for small business.")
                }
                .font(.system(size: 9))
                .foregroundColor(.appLightMuted)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .sheet(isPresented: $showingBusinessProfile) {
            BusinessProfileView().environmentObject(store)
        }
    }

    private var profileCard: some View {
        Button {
            showingBusinessProfile = true
        } label: {
            HStack(spacing: 13) {
                Circle()
                    .fill(LinearGradient(colors: [.appSlate, Color(hex: "34476C")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 54, height: 54)
                    .overlay(Text(store.business.ownerInitials).font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.business.ownerName).font(.system(size: 18, weight: .bold)).foregroundColor(.primary)
                    Text("\(store.business.role) · \(store.business.businessName)").font(.appCaption()).foregroundColor(.appMuted)
                }
                Spacer()
                Image(systemName: "pencil").font(.system(size: 13)).foregroundColor(.appMuted)
            }
        }
        .buttonStyle(.press)
        .padding(.vertical, 6)
    }

    private func settingsCard(_ group: SettingsGroup) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(group.rows.enumerated()), id: \.element.id) { index, row in
                settingsRow(row)
                if index < group.rows.count - 1 {
                    Divider().background(Color.appLine)
                }
            }
        }
        .appCard(padding: 0)
    }

    @ViewBuilder
    private func settingsRow(_ row: SettingsRow) -> some View {
        if row.title == "Face ID" {
            HStack(spacing: 11) {
                iconTile(row.iconName)
                VStack(alignment: .leading, spacing: 3) {
                    Text(row.title).font(.appRowTitle())
                    Text(store.faceIDEnabled ? "Enabled" : "Disabled").font(.appCaption()).foregroundColor(.appMuted)
                }
                Spacer()
                Toggle("", isOn: $store.faceIDEnabled)
                    .labelsHidden()
                    .tint(.appTeal)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 59)
        } else {
            Button {
                if row.title == "Suppliers & Map" {
                    router.go(.suppliers)
                } else if row.title == "Business profile" {
                    showingBusinessProfile = true
                }
            } label: {
                HStack(spacing: 11) {
                    iconTile(row.iconName)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(row.title).font(.appRowTitle()).foregroundColor(.primary)
                        Text(rowSubtitle(for: row))
                            .font(.appCaption()).foregroundColor(.appMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(.appMuted)
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 59)
            }
            .buttonStyle(.press)
        }
    }

    private func rowSubtitle(for row: SettingsRow) -> String {
        switch row.title {
        case "Suppliers & Map": return "\(store.suppliers.count) suppliers"
        case "Business profile": return store.business.businessName
        default: return row.subtitle
        }
    }

    private func iconTile(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 15))
            .foregroundColor(Color(hex: "56667D"))
            .frame(width: 34, height: 34)
            .background(Color(hex: "EDF1F6"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    SettingsView().environmentObject(AppRouter()).environmentObject(MockDataStore()).environmentObject(AuthStore())
}
