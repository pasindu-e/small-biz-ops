import SwiftUI

struct AgentResultsView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @State private var showTrace = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Today's brief", onBack: { router.go(.home) }) {
                    StatusBadge(text: "Ready", tone: .success)
                }

                resultHero
                factLegend
                    .padding(.top, 10)

                HStack {
                    Text("Priority findings").font(.appSectionTitle())
                    Spacer()
                    if highPriorityCount > 0 {
                        StatusBadge(text: "\(highPriorityCount) high", tone: .danger)
                    }
                }
                .padding(.top, 22)
                .padding(.bottom, 10)

                ForEach(store.displayedFindings) { finding in
                    FindingCard(finding: finding) {
                        router.go(finding.destination)
                    }
                    .padding(.bottom, 10)
                }

                if !store.displayedFindings.isEmpty {
                    PrimaryButton(title: "Create \(store.displayedFindings.count) Task\(store.displayedFindings.count == 1 ? "" : "s")", systemImage: "checkmark") {
                        router.go(.tasks)
                    }
                }
                if let reorderSKU = firstReorderSKU {
                    SecondaryButton(title: "Review Reorder") {
                        router.go(.reorder(sku: reorderSKU))
                    }
                }

                traceToggle
                    .padding(.top, 8)

                if showTrace {
                    traceCard
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
    }

    private var resultHero: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "C8F3EB"), Color(hex: "EDFFFB")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(Circle().stroke(Color(hex: "A6E8DC"), lineWidth: 1))
                    .frame(width: 50, height: 50)
                Image(systemName: "checkmark").font(.system(size: 20, weight: .bold)).foregroundColor(Color(hex: "057565"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(store.latestAgentSummary ?? "Your operations are ready").font(.system(size: 20, weight: .bold))
                Text("\(store.displayedFindings.count) finding\(store.displayedFindings.count == 1 ? "" : "s") · \(store.latestAgentSummary != nil ? "Prepared on-device" : "Rule-based review")")
                    .font(.appCaption()).foregroundColor(.appMuted)
            }
        }
        .padding(.vertical, 12)
    }

    private var highPriorityCount: Int {
        store.displayedFindings.filter { $0.severity == .highPriority }.count
    }

    private var firstReorderSKU: String? {
        for finding in store.displayedFindings {
            if case .product(let sku) = finding.destination { return sku }
        }
        return nil
    }

    private var factLegend: some View {
        HStack(spacing: 6) {
            Circle().fill(Color.appSlate).frame(width: 7, height: 7)
            Text("Business fact").font(.system(size: 10)).foregroundColor(.appMuted)
            Circle().fill(Color(hex: "7783DD")).frame(width: 7, height: 7).padding(.leading, 4)
            Text("AI suggestion").font(.system(size: 10)).foregroundColor(.appMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color(hex: "F0F3F7"))
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private var traceToggle: some View {
        Button {
            withAnimation { showTrace.toggle() }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Agent reasoning & tool trace").font(.system(size: 12, weight: .semibold)).foregroundColor(.primary)
                    Text("See how these findings were prepared").font(.system(size: 10)).foregroundColor(.appMuted)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.appMuted)
                    .rotationEffect(.degrees(showTrace ? 180 : 0))
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 4)
            .overlay(Rectangle().fill(Color.appLine).frame(height: 1), alignment: .top)
        }
        .buttonStyle(.press)
    }

    private var traceCard: some View {
        VStack(spacing: 0) {
            ForEach(store.latestAgentTrace ?? []) { line in
                HStack(spacing: 9) {
                    StatusBadge(text: line.label, tone: line.tone)
                    Text(line.detail).font(.system(size: 10)).foregroundColor(.appMuted)
                }
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .appCard(padding: 0)
    }
}

private struct FindingCard: View {
    let finding: AgentFinding
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    StatusBadge(text: finding.severity.rawValue, tone: finding.severity.tone)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(.appMuted)
                }
                Text(finding.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 12)
                    .padding(.bottom, 9)

                if let factLabel = finding.factLabel, let factValue = finding.factValue, let copy = finding.copy {
                    HStack(spacing: 7) {
                        Text(factLabel).font(.system(size: 8, weight: .heavy)).tracking(0.7).foregroundColor(.appSlate)
                        (Text(factValue).font(.system(size: 11, weight: .bold)).foregroundColor(.appSlate) + Text(" \(copy)").font(.system(size: 11)).foregroundColor(.appMuted))
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "F3F5F8"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else if let copy = finding.copy {
                    Text(copy).font(.system(size: 12)).foregroundColor(.appMuted).lineSpacing(3)
                }

                if let suggestion = finding.suggestion {
                    HStack(alignment: .top, spacing: 7) {
                        Image(systemName: "sparkles").font(.system(size: 13)).foregroundColor(Color(hex: "5A63AD"))
                        (Text("Suggested next step\n").font(.system(size: 10, weight: .bold)) + Text(suggestion).font(.system(size: 10)))
                            .foregroundColor(Color(hex: "5A63AD"))
                            .lineSpacing(3)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "F2F2FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.top, 7)
                }
            }
            .padding(15)
        }
        .buttonStyle(.press)
        .appCard(padding: 0)
    }
}

#Preview {
    AgentResultsView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
