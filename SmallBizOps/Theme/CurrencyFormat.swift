import Foundation

private let usdFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    formatter.currencyCode = "USD"
    return formatter
}()

extension Double {
    /// Always renders as "$1,234.56" regardless of the device's region settings,
    /// matching the React prototype's hardcoded "$" formatting.
    func asUSD() -> String {
        usdFormatter.string(from: NSNumber(value: self)) ?? "$\(String(format: "%.2f", self))"
    }
}
