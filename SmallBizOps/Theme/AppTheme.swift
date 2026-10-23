import SwiftUI

enum AppRadius {
    static let lg: CGFloat = 22
    static let md: CGFloat = 16
    static let sm: CGFloat = 12
}

enum AppShadow {
    static let card = Color.appNavy.opacity(0.045)
    static let elevated = Color.appNavy.opacity(0.14)
}

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}

/// Shared card surface matching the React prototype's `.card` style.
struct CardBackground: ViewModifier {
    var padding: CGFloat = 14
    var cornerRadius: CGFloat = AppRadius.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.appLine.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: AppShadow.card, radius: 12, x: 0, y: 5)
    }
}

extension View {
    func appCard(padding: CGFloat = 14, cornerRadius: CGFloat = AppRadius.md) -> some View {
        modifier(CardBackground(padding: padding, cornerRadius: cornerRadius))
    }
}

/// Button style that mimics the `.press` scale/opacity feedback from the prototype.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressStyle {
    static var press: PressStyle { PressStyle() }
}
