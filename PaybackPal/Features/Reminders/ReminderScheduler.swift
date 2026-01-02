import Foundation
import UserNotifications

class ReminderScheduler: ObservableObject {
    static let shared = ReminderScheduler()
    
    @Published var hasPermission: Bool = false
    @Published var remindersScheduled: Bool = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        checkPermissionStatus()
        checkScheduledReminders()
    }
    
    func requestPermission() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                hasPermission = granted
                if granted {
                    checkScheduledReminders()
                }
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func scheduleBiweeklyReminders() {
        guard hasPermission else { return }
        
        let paydays = DateHelpers.nextPaydays(count: 6)
        
        for (index, payday) in paydays.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Payback time"
            content.body = "Payday reminder: make a payment and update the balance."
            content.sound = .default
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: payday)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "payday-reminder-\(index)",
                content: content,
                trigger: trigger
            )
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
        
        checkScheduledReminders()
    }
    
    func clearScheduledReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
        remindersScheduled = false
    }
    
    private func checkPermissionStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func checkScheduledReminders() {
        notificationCenter.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.remindersScheduled = !requests.isEmpty
            }
        }
    }
}

