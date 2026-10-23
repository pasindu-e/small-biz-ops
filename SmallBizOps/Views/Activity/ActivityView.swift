import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                summary
                    .padding(.top, 4)

                HStack {
                    Text("Recent activity").font(.appSectionTitle())
                    Spacer()
                    Button("Filter") {}
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.appBlue)
                        .buttonStyle(.press)
                }
                .padding(.top, 22)
                .padding(.bottom, 10)

                if let todayRun = store.todayRun {
                    RunCard(run: todayRun) { router.go(.runDetail) }
                        .padding(.bottom, 10)
                }

                Text("YESTERDAY")
                    .font(.system(size: 10, weight: .heavy)).tracking(1.1)
                    .foregroundColor(.appLightMuted)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ForEach(store.activityEvents) { event in
                    activityRow(event)
                        .padding(.bottom, 8)
                }

                if let yesterdayRun = store.yesterdayRun {
                    RunCard(run: yesterdayRun) { router.go(.runDetail) }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity").font(.appHeroTitle())
                Text("Your business operations record").font(.appCaption()).foregroundColor(.appMuted)
            }
            Spacer()
            Button {} label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.appNavy)
                    .clipShape(Circle())
            }
            .buttonStyle(.press)
        }
    }

    private var summary: some View {
        HStack(spacing: 0) {
            summaryItem(value: "\(store.agentRuns.count)", label: "Agent runs")
            Divider().overlay(Color.white.opacity(0.12))
            summaryItem(value: "\(store.agentRuns.reduce(0) { $0 + $1.findingsCount })", label: "Issues found")
            Divider().overlay(Color.white.opacity(0.12))
            summaryItem(value: "\(store.tasks.count)", label: "Tasks created")
        }
        .padding(.vertical, 15)
        .background(LinearGradient(colors: [.appNavy, Color(hex: "273859")], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private func summaryItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 9)).foregroundColor(Color(hex: "A8B3C5"))
        }
        .frame(maxWidth: .infinity)
    }

    private func activityRow(_ event: ActivityEvent) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(event.isApproved ? Color.badgeSuccessBG : Color.appIce)
                    .frame(width: 33, height: 33)
                Image(systemName: "checkmark")
                    .foregroundColor(event.isApproved ? .appSuccess : .appBlue)
                    .font(.system(size: 14))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(event.title).font(.appRowTitle())
                Text(event.subtitle).font(.appCaption()).foregroundColor(.appMuted)
            }
            Spacer()
            Text(event.time).font(.system(size: 9)).foregroundColor(.appLightMuted)
        }
        .padding(12)
        .appCard(padding: 0)
    }
}

private struct RunCard: View {
    let run: AgentRun
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Color.appNavy).frame(width: 34, height: 34)
                        Image(systemName: "sparkles").font(.system(size: 15)).foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(run.title).font(.appRowTitle()).foregroundColor(.primary)
                        Text("\(run.dateLabel) · \(run.timeLabel) · \(run.duration)").font(.appCaption()).foregroundColor(.appMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(.appMuted)
                }
                HStack(spacing: 13) {
                    (Text("\(run.findingsCount) ").fontWeight(.bold) + Text("findings")).font(.system(size: 9)).foregroundColor(.appMuted)
                    (Text("\(run.tasksCount) ").fontWeight(.bold) + Text("tasks")).font(.system(size: 9)).foregroundColor(.appMuted)
                    StatusBadge(text: run.reviewState.rawValue, tone: run.reviewState == .approved ? .success : .neutral)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 0)
                .overlay(Rectangle().fill(Color.appLine).frame(height: 1), alignment: .top)
            }
            .padding(14)
        }
        .buttonStyle(.press)
        .appCard(padding: 0)
    }
}

#Preview {
    ActivityView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
