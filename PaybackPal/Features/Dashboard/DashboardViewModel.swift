import Foundation
import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    // Dependencies
    let repository: PaymentsRepository
    let reminderScheduler: ReminderScheduler

    // View state
    @Published private(set) var debtData: DebtData

    // Expose reminder state for the View
    var hasNotificationPermission: Bool {
        reminderScheduler.hasPermission
    }

    var remindersScheduled: Bool {
        reminderScheduler.remindersScheduled
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Derived UI values

    var currentBalance: Decimal {
        debtData.currentBalance
    }

    var recentPayments: [Payment] {
        debtData.payments.sorted { $0.date > $1.date }
    }

    var estimatedPayoffDate: Date? {
        let balance = currentBalance
        let biweeklyPayment = debtData.paycheckPaymentAmount

        guard biweeklyPayment > 0 else { return nil }

        let nextPayday = DateHelpers.nextPayday()
        return DateHelpers.estimatePayoffDate(
            balance: balance,
            biweeklyPayment: biweeklyPayment,
            startDate: nextPayday
        )
    }

    // MARK: - Init

    init(
        repository: PaymentsRepository = .shared,
        reminderScheduler: ReminderScheduler = .shared
    ) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
        self.debtData = repository.debtData

        // Keep ViewModel state in sync with repository changes
        repository.$debtData
            .sink { [weak self] newData in
                self?.debtData = newData
            }
            .store(in: &cancellables)

        // Optional: If you find reminder status is not updating in the UI,
        // we can also subscribe to reminderScheduler publisher changes and
        // trigger objectWillChange, but start simple first.
    }

    // MARK: - Payments

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

    // MARK: - Notifications

    func requestNotificationPermission() {
        Task {
            await reminderScheduler.requestPermission()
        }
    }

    func scheduleReminders() {
        Task {
            await reminderScheduler.scheduleBiweeklyReminders()
        }
    }

    func clearReminders() {
        Task {
            await reminderScheduler.clearScheduledPaydayReminders()
        }
    }
}