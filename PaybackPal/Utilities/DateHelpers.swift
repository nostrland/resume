import Foundation

struct DateHelpers {
    /// Finds the next payday (every other Wednesday) from a given date
    static func nextPayday(from date: Date = Date()) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        // Set to 9:00 AM
        components.hour = 9
        components.minute = 0
        components.second = 0
        
        guard var candidate = calendar.date(from: components) else {
            return date
        }
        
        // Find the next Wednesday
        while calendar.component(.weekday, from: candidate) != 4 { // 4 = Wednesday
            candidate = calendar.date(byAdding: .day, value: 1, to: candidate) ?? candidate
        }
        
        // If today is Wednesday and it's before 9 AM, use today
        let today = calendar.date(from: components) ?? date
        if calendar.isDate(today, inSameDayAs: candidate) && date < candidate {
            return candidate
        }
        
        // If we found a Wednesday that's today or in the past, move to next biweekly
        if candidate <= date {
            candidate = calendar.date(byAdding: .day, value: 14, to: candidate) ?? candidate
        }
        
        return candidate
    }
    
    /// Gets the next N paydays (every other Wednesday)
    static func nextPaydays(count: Int, from date: Date = Date()) -> [Date] {
        var paydays: [Date] = []
        var currentDate = nextPayday(from: date)
        
        for _ in 0..<count {
            paydays.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 14, to: currentDate) ?? currentDate
        }
        
        return paydays
    }
    
    /// Estimates payoff date based on balance and biweekly payment amount
    static func estimatePayoffDate(balance: Decimal, biweeklyPayment: Decimal, startDate: Date = Date()) -> Date? {
        guard biweeklyPayment > 0 else { return nil }
        
        let periods = ceil((balance / biweeklyPayment).doubleValue)
        let days = Int(periods) * 14
        
        return Calendar.current.date(byAdding: .day, value: days, to: startDate)
    }
}

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}

