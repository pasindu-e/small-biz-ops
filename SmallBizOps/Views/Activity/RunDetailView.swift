import SwiftUI

private struct ReportPreviewItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct RunDetailView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @State private var reportPreviewItem: ReportPreviewItem?

    private var run: AgentRun? { store.todayRun }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Execution detail", onBack: { router.go(.activity) }) {
                    StatusBadge(text: "Complete", tone: .success)
                }

                if let run {
                    hero(run)
                    stats(run)
                        .padding(.top, 4)

                    Text("Execution trace").font(.appSectionTitle()).padding(.top, 22).padding(.bottom, 10)
                    executionList(run)

                    privacyCard
                        .padding(.top, 12)

                    PrimaryButton(title: "Export PDF Report", systemImage: "doc.richtext") {
                        let url = PDFReportGenerator.makeRunReport(for: run)
                        reportPreviewItem = ReportPreviewItem(url: url)
                    }
                    .padding(.top, 16)
                } else {
                    Text("No run data yet.").font(.appCaption()).foregroundColor(.appMuted).padding(.top, 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .fullScreenCover(item: $reportPreviewItem) { item in
            PDFReportPreviewScreen(url: item.url) {
                reportPreviewItem = nil
            }
        }
    }

    private func hero(_ run: AgentRun) -> some View {
        VStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.appNavy).frame(width: 44, height: 44)
                Image(systemName: "sparkles").font(.system(size: 21)).foregroundColor(.white)
            }
            Text("Daily operations run").font(.system(size: 20, weight: .bold))
            Text("\(run.dateLabel) at \(run.timeLabel) · Completed in \(run.duration)")
                .font(.appCaption()).foregroundColor(.appMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
    }

    private func stats(_ run: AgentRun) -> some View {
        HStack(spacing: 0) {
            statItem(value: "\(run.findingsCount)", label: "Issues")
            Divider().background(Color.appLine)
            statItem(value: "\(run.tasksCount)", label: "Tasks")
            Divider().background(Color.appLine)
            statItem(value: "\(run.toolCallsCount)", label: "Tool calls")
        }
        .padding(13)
        .appCard(padding: 0)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 19, weight: .bold))
            Text(label).font(.system(size: 9)).foregroundColor(.appMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private func executionList(_ run: AgentRun) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(run.executionTrace.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 11) {
                    ZStack {
                        Circle()
                            .fill(index == run.executionTrace.count - 1 ? Color.appNavy : Color(hex: "EDF0F4"))
                            .frame(width: 27, height: 27)
                        if index == run.executionTrace.count - 1 {
                            Image(systemName: "sparkles").font(.system(size: 12)).foregroundColor(.white)
                        } else {
                            Text("\(index + 1)").font(.system(size: 10, weight: .bold))
                        }
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 5) {
                        StatusBadge(text: step.kind, tone: step.kind == "RESULT" ? .success : (step.kind == "TOOL CALL" ? .info : .neutral))
                        Text(step.title).font(.appRowTitle()).padding(.top, 2)
                        Text(step.copy).font(.appCaption()).foregroundColor(.appMuted)
                    }
                    .padding(.vertical, 8)
                }
                .frame(minHeight: 82, alignment: .top)
                if index < run.executionTrace.count - 1 {
                    Divider().background(Color.appLine.opacity(0.6)).padding(.leading, 38)
                }
            }
        }
        .padding(.horizontal, 13).padding(.vertical, 7)
        .appCard(padding: 0)
    }

    private var privacyCard: some View {
        HStack(spacing: 11) {
            Image(systemName: "shield.fill").font(.system(size: 20)).foregroundColor(Color(hex: "416991"))
            VStack(alignment: .leading, spacing: 3) {
                Text("Processed on device").font(.appRowTitle())
                Text("Business data used in this run stayed on your iPhone.").font(.appCaption()).foregroundColor(.appMuted)
            }
        }
        .padding(13)
        .background(Color(hex: "EDF7FF"))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }
}

#Preview {
    RunDetailView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
