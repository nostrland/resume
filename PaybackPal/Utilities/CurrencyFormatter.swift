import Foundation

struct CurrencyFormatter {
    static let shared = CurrencyFormatter()
    
    private let formatter: NumberFormatter
    
    private init() {
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
    }
    
    func string(from amount: Decimal) -> String {
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

