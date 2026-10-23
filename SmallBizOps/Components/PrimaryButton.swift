import SwiftUI

struct PrimaryButton: View {
    enum Style { case dark, light, mint, disabledSuccess }

    let title: String
    var systemImage: String? = nil
    var trailingArrow: Bool = false
    var style: Style = .dark
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                if trailingArrow {
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .font(.appButton())
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.horizontal, 18)
            .foregroundColor(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.press)
    }

    private var background: some ShapeStyle {
        switch style {
        case .dark: return AnyShapeStyle(Color.appNavy)
        case .light: return AnyShapeStyle(Color.white)
        case .mint: return AnyShapeStyle(LinearGradient(colors: [.appTeal, Color(hex: "7CE5D8")], startPoint: .topLeading, endPoint: .bottomTrailing))
        case .disabledSuccess: return AnyShapeStyle(Color.appSuccess)
        }
    }

    private var foreground: Color {
        switch style {
        case .dark, .mint, .disabledSuccess: return .white
        case .light: return .appNavy
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appButton())
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundColor(.appSlate)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color(hex: "D8DEE8"), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.press)
    }
}
