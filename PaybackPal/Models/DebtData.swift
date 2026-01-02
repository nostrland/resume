import Foundation

struct DebtData: Codable {
    var originalAmount: Decimal
    var payments: [Payment]
    var paycheckPaymentAmount: Decimal

    var currentBalance: Decimal {
        let totalPaid = payments.reduce(Decimal(0)) { partial, payment in
            partial + max(Decimal(0), payment.amount)
        }
        return max(Decimal(0), originalAmount - totalPaid)
    }

    var isPaidOff: Bool {
        currentBalance == 0
    }

    init(
        originalAmount: Decimal = 5055.00,
        payments: [Payment] = [],
        paycheckPaymentAmount: Decimal = 0
    ) {
        self.originalAmount = originalAmount
        self.payments = payments
        self.paycheckPaymentAmount = paycheckPaymentAmount
    }
}