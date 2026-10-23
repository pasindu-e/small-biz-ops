import Foundation
import FoundationModels

/// Runs the daily operations review using Apple's on-device Foundation Models
/// framework (iOS 26+, Apple Intelligence–capable devices only). Falls back to
/// `MockDataStore.findings` (plain rule-based logic) everywhere else, so the
/// feature degrades gracefully instead of failing.
@MainActor
final class AgentService: ObservableObject {
    enum Status {
        case idle
        case running
        case finished(summary: String, findings: [AgentFinding])
        case unavailable(String)
        case failed(String)
    }

    @Published private(set) var status: Status = .idle

    func run(products: [Product], orders: [Order]) async {
        status = .running

        guard #available(iOS 26.0, *) else {
            status = .unavailable("On-device AI requires iOS 26 or later.")
            return
        }
        await runOnDevice(products: products, orders: orders)
    }

    @available(iOS 26.0, *)
    private func runOnDevice(products: [Product], orders: [Order]) async {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(let reason):
            status = .unavailable(Self.unavailableMessage(reason))
            return
        }

        let session = LanguageModelSession(instructions: Self.instructions)
        let prompt = Self.buildPrompt(products: products, orders: orders)

        do {
            let response = try await session.respond(to: prompt, generating: GeneratedBrief.self)
            status = .finished(
                summary: response.content.summary,
                findings: Self.mapFindings(response.content.findings, products: products, orders: orders)
            )
        } catch {
            status = .failed("The on-device model couldn't complete this run: \(error.localizedDescription)")
        }
    }

    @available(iOS 26.0, *)
    private static func unavailableMessage(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "This device doesn't support Apple Intelligence."
        case .appleIntelligenceNotEnabled:
            return "Turn on Apple Intelligence in Settings to use the on-device agent."
        case .modelNotReady:
            return "The on-device model is still downloading. Try again shortly."
        @unknown default:
            return "The on-device AI model isn't available right now."
        }
    }

    private static let instructions = """
    You are an operations assistant for a small retail business. You will be given the current \
    inventory and open orders as plain data. Identify genuine operational issues: stock at or below \
    its minimum, and orders that are delayed. Propose one concrete, specific next step for each issue. \
    Only ever reference SKUs and order IDs exactly as given in the data; never invent one. If nothing \
    needs attention, return an empty findings list. Keep language concise, factual, and grounded only \
    in the data provided.
    """

    private static func buildPrompt(products: [Product], orders: [Order]) -> String {
        var lines = ["INVENTORY:"]
        for product in products {
            lines.append("- SKU \(product.sku) | \(product.name) | stock \(product.stock) | minimum \(product.minimum) | status \(product.status.rawValue)")
        }
        lines.append("")
        lines.append("OPEN ORDERS:")
        for order in orders {
            lines.append("- \(order.id) | customer \(order.customer) | status \(order.status.rawValue) | \(order.time)")
        }
        lines.append("")
        lines.append("Review this data and prepare today's operations brief.")
        return lines.joined(separator: "\n")
    }

    @available(iOS 26.0, *)
    private static func mapFindings(_ generated: [GeneratedFinding], products: [Product], orders: [Order]) -> [AgentFinding] {
        let skus = Set(products.map(\.sku))
        let orderIDs = Set(orders.map(\.id))

        return generated.compactMap { item -> AgentFinding? in
            let destination: Screen
            if skus.contains(item.relatedID) {
                destination = .product(sku: item.relatedID)
            } else if orderIDs.contains(item.relatedID) {
                destination = .order(id: item.relatedID)
            } else {
                // Drop findings that reference data we never actually provided (hallucination guard).
                return nil
            }

            let severity: FindingSeverity = item.severity.lowercased().contains("high") ? .highPriority : .medium

            return AgentFinding(
                severity: severity,
                title: item.title,
                factLabel: nil,
                factValue: nil,
                copy: item.explanation,
                suggestion: item.suggestion,
                destination: destination
            )
        }
    }
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedBrief {
    @Guide(description: "One encouraging sentence summarizing today's operational state")
    var summary: String
    @Guide(description: "0 to 4 findings about stock or delayed orders that genuinely need attention, most urgent first")
    var findings: [GeneratedFinding]
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedFinding {
    @Guide(description: "'high' if urgent, otherwise 'medium'")
    var severity: String
    @Guide(description: "Short title under 10 words describing the issue")
    var title: String
    @Guide(description: "1-2 sentence factual explanation grounded in the given data")
    var explanation: String
    @Guide(description: "One concrete next step the owner should take")
    var suggestion: String
    @Guide(description: "The exact SKU or order ID from the given data that this finding is about")
    var relatedID: String
}
