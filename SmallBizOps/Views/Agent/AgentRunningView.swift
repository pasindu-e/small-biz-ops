import SwiftUI

private struct AgentStep {
    let title: String
    let subtitle: String
    let icon: String
}

struct AgentRunningView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @StateObject private var agentService = AgentService()
    @State private var step = 1
    @State private var pulse = false

    private let stepDurations: [Double] = [0.8, 0.8, 1.0, 1.0]

    private var agentSteps: [AgentStep] {
        [
            AgentStep(title: "Reviewing inventory levels", subtitle: "\(store.products.count) products scanned", icon: "viewfinder"),
            AgentStep(title: "Checking open orders", subtitle: "\(store.orders.count) orders reviewed", icon: "doc.text"),
            AgentStep(title: "Identifying operational issues", subtitle: "Comparing thresholds & due dates", icon: "exclamationmark.triangle"),
            AgentStep(title: "Preparing recommended actions", subtitle: "Prioritizing your next steps", icon: "sparkles"),
        ]
    }

    /// The animated timeline is purely for pacing; the real result only shows
    /// once both the animation and the actual agent run have finished.
    private var agentIsReady: Bool {
        switch agentService.status {
        case .finished, .unavailable, .failed: return true
        case .idle, .running: return false
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "Daily preparation") {
                router.go(.home)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 0) {
                    runHero
                    timeline
                        .padding(.top, 17)
                    Spacer(minLength: 17)
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(
            RadialGradient(colors: [Color(hex: "24335B"), .appNavy], center: UnitPoint(x: 0.5, y: 0.18), startRadius: 0, endRadius: 420)
                .ignoresSafeArea()
        )
        .onAppear {
            runSequence()
            Task {
                await agentService.run(products: store.products, orders: store.orders)
                applyResultIfFinished()
            }
        }
        .onChange(of: step) { _, _ in applyResultIfFinished() }
    }

    private func runSequence() {
        guard step < 4 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDurations[step - 1]) {
            withAnimation(.easeInOut(duration: 0.3)) {
                step += 1
            }
            runSequence()
        }
    }

    /// Publishes the agent's result into the shared store once available, so
    /// `AgentResultsView` can display it. No-ops until both the run finishes
    /// and the intro animation reaches its final step.
    private func applyResultIfFinished() {
        guard step == 4 else { return }
        let productCount = store.products.count
        let orderCount = store.orders.count

        switch agentService.status {
        case .finished(let summary, let findings):
            store.latestAgentSummary = summary
            store.latestAgentFindings = findings
            store.latestAgentTrace = [
                TraceLine(tone: .info, label: "PLAN", detail: "Check stock against saved thresholds and review open orders"),
                TraceLine(tone: .neutral, label: "TOOL", detail: "Firestore.products.read → \(productCount) records"),
                TraceLine(tone: .neutral, label: "TOOL", detail: "Firestore.orders.read → \(orderCount) records"),
                TraceLine(tone: .neutral, label: "TOOL", detail: "SystemLanguageModel.respond → on-device model call"),
                TraceLine(tone: .success, label: "RESULT", detail: "\(findings.count) operational issue\(findings.count == 1 ? "" : "s") identified"),
            ]
        case .unavailable(let reason), .failed(let reason):
            store.latestAgentSummary = nil
            store.latestAgentFindings = nil
            store.latestAgentTrace = [
                TraceLine(tone: .info, label: "PLAN", detail: "Check stock against saved thresholds and review open orders"),
                TraceLine(tone: .neutral, label: "TOOL", detail: "Firestore.products.read → \(productCount) records"),
                TraceLine(tone: .neutral, label: "TOOL", detail: "Firestore.orders.read → \(orderCount) records"),
                TraceLine(tone: .warning, label: "FALLBACK", detail: reason),
                TraceLine(tone: .success, label: "RESULT", detail: "Rule-based scan applied instead"),
            ]
        case .idle, .running:
            break
        }
    }

    private var runHero: some View {
        VStack(spacing: 9) {
            ZStack {
                Circle()
                    .fill(Color.appIndigo.opacity(0.08))
                    .overlay(Circle().stroke(Color.appIndigo.opacity(0.18), lineWidth: 1))
                    .frame(width: 92, height: 92)
                    .scaleEffect(pulse ? 1.04 : 1.0)
                    .shadow(color: Color.appTeal.opacity(0.25), radius: pulse ? 34 : 20)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                    }
                Circle()
                    .fill(LinearGradient(colors: [.appIndigo, .appTeal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                Image(systemName: "sparkles").font(.system(size: 24)).foregroundColor(.appNavy)
            }
            .padding(.bottom, 11)

            Text("OPERATIONS AGENT").font(.appEyebrow()).foregroundColor(.appTeal)
            Text(step == 4 && agentIsReady ? "Your plan is ready" : "Preparing your day")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
            Text(heroSubtitle)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "A9B4C6"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .lineSpacing(4)
        }
        .padding(.top, 23)
        .padding(.bottom, 26)
    }

    private var timeline: some View {
        VStack(spacing: 0) {
            ForEach(Array(agentSteps.enumerated()), id: \.offset) { index, item in
                let number = index + 1
                let state: TimelineState = number < step || step == 4 ? .done : (number == step ? .active : .pending)
                TimelineRow(step: item, state: state, showLine: index < agentSteps.count - 1)
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private var heroSubtitle: String {
        guard step == 4 else {
            return "Reviewing your business data securely on this device."
        }
        switch agentService.status {
        case .finished(_, let findings):
            return findings.isEmpty
                ? "Nothing needs your attention today."
                : "I found \(findings.count) item\(findings.count == 1 ? "" : "s") that need\(findings.count == 1 ? "s" : "") your attention."
        case .unavailable(let reason):
            return "\(reason) Showing rule-based insights instead."
        case .failed(let reason):
            return "\(reason) Showing rule-based insights instead."
        case .idle, .running:
            return "Finishing up…"
        }
    }

    @ViewBuilder
    private var footer: some View {
        if step == 4 && agentIsReady {
            PrimaryButton(title: "View My Operations Brief", trailingArrow: true, style: .mint) {
                router.go(.results)
            }
        } else {
            HStack(spacing: 7) {
                Image(systemName: "shield").font(.system(size: 13))
                Text("No changes are made without your approval").font(.system(size: 10))
            }
            .foregroundColor(Color(hex: "7F8BA0"))
            .frame(maxWidth: .infinity)
        }
    }
}

private enum TimelineState { case done, active, pending }

private struct TimelineRow: View {
    let step: AgentStep
    let state: TimelineState
    let showLine: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(state == .done ? Color.appTeal : Color(hex: "1B263B"))
                        .overlay(
                            Circle().stroke(nodeStroke, lineWidth: 1)
                        )
                        .frame(width: 29, height: 29)
                        .shadow(color: state == .active ? Color.appIndigo.opacity(0.24) : .clear, radius: 8)
                    if state == .done {
                        Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(.appNavy)
                    } else {
                        Image(systemName: step.icon).font(.system(size: 14)).foregroundColor(nodeIconColor)
                    }
                }
                .padding(.top, 14)
                if showLine {
                    Rectangle()
                        .fill(state == .done ? Color.appTeal : Color(hex: "344057"))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 5) {
                Text(step.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(titleColor)
                Text(state == .pending ? "Waiting" : step.subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(subtitleColor)
            }
            .padding(.top, 16)
            .padding(.leading, 10)

            Spacer()

            if state == .active {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .appTeal))
                    .padding(.top, 23)
                    .padding(.trailing, 6)
            }
        }
        .frame(minHeight: 74)
    }

    private var nodeStroke: Color {
        switch state {
        case .done: return .appTeal
        case .active: return .appIndigo
        case .pending: return Color(hex: "3B475F")
        }
    }

    private var nodeIconColor: Color {
        state == .active ? .appIndigo : Color(hex: "657089")
    }

    private var titleColor: Color {
        switch state {
        case .done: return Color(hex: "EDF4F9")
        case .active: return .white
        case .pending: return Color(hex: "7E899F")
        }
    }

    private var subtitleColor: Color {
        switch state {
        case .done: return Color(hex: "8795AA")
        case .active: return .appIndigo
        case .pending: return Color(hex: "59667E")
        }
    }
}

#Preview {
    AgentRunningView().environmentObject(AppRouter())
}
