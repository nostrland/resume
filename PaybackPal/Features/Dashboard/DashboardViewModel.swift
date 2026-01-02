import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var repository: PaymentsRepository
    @Published var reminderScheduler: ReminderScheduler
    
    var currentBalance: Decimal {
        repository.debtData.currentBalance
    }
    
    var recentPayments: [Payment] {
        repository.debtData.payments.sorted { $0.date > $1.date }
    }
    
    var estimatedPayoffDate: Date? {
        let balance = currentBalance
        let biweeklyPayment = repository.debtData.paycheckPaymentAmount
        
        guard biweeklyPayment > 0 else { return nil }
        
        let nextPayday = DateHelpers.nextPayday()
        return DateHelpers.estimatePayoffDate(
            balance: balance,
            biweeklyPayment: biweeklyPayment,
            startDate: nextPayday
        )
    }
    
    init(repository: PaymentsRepository = .shared, reminderScheduler: ReminderScheduler = .shared) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }
    
    func addQuickPayment(_ amount: Decimal) {
        let payment = Payment(amount: amount)
        repository.addPayment(payment)
    }
    
    func deletePayment(_ payment: Payment) {
        repository.deletePayment(payment)
    }
    
    func updatePaycheckAmount(_ amount: Decimal) {
        repository.updatePaycheckPaymentAmount(amount)
    }
    
    func requestNotificationPermission() {
        Task {
            await reminderScheduler.requestPermission()
        }
    }
    
    func scheduleReminders() {
        reminderScheduler.scheduleBiweeklyReminders()
    }
    
    func clearReminders() {
        reminderScheduler.clearScheduledReminders()
    }
}

