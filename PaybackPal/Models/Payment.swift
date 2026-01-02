import Foundation

struct Payment: Identifiable, Codable {
    let id: UUID
    let amount: Decimal
    let date: Date

    init(
        id: UUID = UUID(),
        amount: Decimal,
        date: Date = Date()
    ) {
        self.id = id
        self.amount = max(Decimal(0), amount)
        self.date = date
    }
}