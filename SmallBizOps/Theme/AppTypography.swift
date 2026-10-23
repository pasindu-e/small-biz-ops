import SwiftUI

extension Font {
    static func appHeroTitle() -> Font { .system(size: 26, weight: .bold, design: .default) }
    static func appSectionTitle() -> Font { .system(size: 16, weight: .semibold) }
    static func appCardTitle() -> Font { .system(size: 15, weight: .semibold) }
    static func appRowTitle() -> Font { .system(size: 13, weight: .semibold) }
    static func appBody() -> Font { .system(size: 13) }
    static func appCaption() -> Font { .system(size: 11) }
    static func appEyebrow() -> Font { .system(size: 10, weight: .heavy) }
    static func appKPIValue() -> Font { .system(size: 22, weight: .heavy) }
    static func appBadge() -> Font { .system(size: 9, weight: .heavy) }
    static func appButton() -> Font { .system(size: 14, weight: .bold) }
    static func appLargeStat() -> Font { .system(size: 28, weight: .bold) }
}

extension View {
    func eyebrowStyle() -> some View {
        self.font(.appEyebrow()).tracking(1.1).foregroundColor(.appMuted)
    }
}
