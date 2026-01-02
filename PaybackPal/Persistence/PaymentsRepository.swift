import Foundation

class PaymentsRepository: ObservableObject {
    static let shared = PaymentsRepository()
    
    private let userDefaultsKey = "debtData"
    
    @Published var debtData: DebtData {
        didSet {
            save()
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(DebtData.self, from: data) {
            self.debtData = decoded
        } else {
            self.debtData = DebtData()
            save()
        }
    }
    
    func addPayment(_ payment: Payment) {
        debtData.payments.append(payment)
    }
    
    func deletePayment(_ payment: Payment) {
        debtData.payments.removeAll { $0.id == payment.id }
    }
    
    func updatePaycheckPaymentAmount(_ amount: Decimal) {
        debtData.paycheckPaymentAmount = amount
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(debtData) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

