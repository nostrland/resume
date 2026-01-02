import Foundation

final class CurrencyFormatter {
    static let shared = CurrencyFormatter()

    private let formatter: NumberFormatter

    private init() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale.current
        self.formatter = formatter
    }

    func string(from amount: Decimal) -> String {
        formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}