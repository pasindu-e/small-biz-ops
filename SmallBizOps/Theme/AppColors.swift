import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }

    // Core palette (from React prototype src/index.css)
    static let appNavy = Color(hex: "101828")
    static let appSlate = Color(hex: "1D2939")
    static let appMuted = Color(hex: "667085")
    static let appLightMuted = Color(hex: "98A2B3")
    static let appIce = Color(hex: "DCEBFA")
    static let appIndigo = Color(hex: "A5B4FC")
    static let appTeal = Color(hex: "54D6C5")
    static let appOffWhite = Color(hex: "F7F9FC")
    static let appLine = Color(hex: "E7ECF2")
    static let appWarning = Color(hex: "F59E0B")
    static let appDanger = Color(hex: "E65B65")
    static let appSuccess = Color(hex: "159B87")
    static let appBlue = Color(hex: "5278BF")

    // KPI icon tints
    static let kpiBlueBG = Color.appIce
    static let kpiBlueFG = Color.appBlue
    static let kpiIndigoBG = Color(hex: "EAECFF")
    static let kpiIndigoFG = Color(hex: "5D64C7")
    static let kpiCoralBG = Color(hex: "FDEBED")
    static let kpiCoralFG = Color.appDanger

    // Badge tones
    static let badgeNeutralBG = Color(hex: "EFF2F6")
    static let badgeNeutralFG = Color(hex: "566275")
    static let badgeWarningBG = Color(hex: "FFF1CF")
    static let badgeWarningFG = Color(hex: "9B6500")
    static let badgeSuccessBG = Color(hex: "DFF7F2")
    static let badgeSuccessFG = Color(hex: "087968")
    static let badgeInfoBG = Color.appIce
    static let badgeInfoFG = Color(hex: "3B65A5")
    static let badgeDangerBG = Color(hex: "FDE8EA")
    static let badgeDangerFG = Color(hex: "BF3D4A")
}

enum BadgeTone {
    case neutral, warning, success, info, danger

    var background: Color {
        switch self {
        case .neutral: return .badgeNeutralBG
        case .warning: return .badgeWarningBG
        case .success: return .badgeSuccessBG
        case .info: return .badgeInfoBG
        case .danger: return .badgeDangerBG
        }
    }

    var foreground: Color {
        switch self {
        case .neutral: return .badgeNeutralFG
        case .warning: return .badgeWarningFG
        case .success: return .badgeSuccessFG
        case .info: return .badgeInfoFG
        case .danger: return .badgeDangerFG
        }
    }
}
