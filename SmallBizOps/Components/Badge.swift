import SwiftUI

struct StatusBadge: View {
    let text: String
    let tone: BadgeTone

    var body: some View {
        Text(text.uppercased())
            .font(.appBadge())
            .tracking(0.3)
            .foregroundColor(tone.foreground)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(tone.background)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        StatusBadge(text: "Low stock", tone: .danger)
        StatusBadge(text: "In stock", tone: .success)
        StatusBadge(text: "Processing", tone: .info)
        StatusBadge(text: "Pending", tone: .warning)
        StatusBadge(text: "Neutral", tone: .neutral)
    }
    .padding()
}
