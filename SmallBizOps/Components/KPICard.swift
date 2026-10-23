import SwiftUI

struct KPICard: View {
    enum Tint { case blue, indigo, coral }

    let icon: String
    let value: String
    let label: String
    let tint: Tint

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(fg)
                .frame(width: 30, height: 30)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(value)
                .font(.appKPIValue())
                .foregroundColor(.appNavy)
            Text(label)
                .font(.appCaption())
                .foregroundColor(.appMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 12)
    }

    private var bg: Color {
        switch tint {
        case .blue: return .kpiBlueBG
        case .indigo: return .kpiIndigoBG
        case .coral: return .kpiCoralBG
        }
    }

    private var fg: Color {
        switch tint {
        case .blue: return .kpiBlueFG
        case .indigo: return .kpiIndigoFG
        case .coral: return .kpiCoralFG
        }
    }
}
