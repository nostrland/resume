import Foundation

struct DateHelpers {
    /// Business rule for v1:
    /// - The next upcoming Wednesday at 9:00 AM is considered the next payday.
    /// - Future paydays repeat every 14 days from that date.
    ///
    /// If you later want to align to an exact paycheck cycle, we can add an "anchor payday date"
    /// to DebtData and base the cadence off that.
    static func nextPayday(from date: Date = Date()) -> Date {
        let calendar = Calendar.current

        // Find the next Wednesday at 9:00 AM local time
        var components = DateComponents()
        components.weekday = 4 // Wednesday in Gregorian calendar: 1=Sunday ... 4=Wednesday
        components.hour = 9
        components.minute = 0
        components.second = 0

        // .nextTime ensures we always get a future occurrence
        let next = calendar.nextDate(
            after: date,
            matching: components,
            matchingPolicy: .nextTime,
            direction: .forward
        )

        return next ?? date
    }

    /// Gets the next N paydays (biweekly) starting from the next payday.
    static func nextPaydays(count: Int, from date: Date = Date()) -> [Date] {
        guard count > 0 else { return [] }

        var paydays: [Date] = []
        var current = nextPayday(from: date)

        for _ in 0..<count {
            paydays.append(current)
            current = Calendar.current.date(byAdding: .day, value: 14, to: current) ?? current
        }

        return paydays
    }

    /// Estimates payoff date based on remaining balance and biweekly payment amount.
    /// - If biweeklyPayment <= 0: returns nil
    /// - If balance <= 0: returns startDate (already paid off)
    ///
    /// Uses Decimal-safe rounding up to the next whole pay period.
    static func estimatePayoffDate(
        balance: Decimal,
        biweeklyPayment: Decimal,
        startDate: Date
    ) -> Date? {
        guard biweeklyPayment > 0 else { return nil }
        guard balance > 0 else { return startDate }

        let periods = DecimalMath.divideAndRoundUp(balance, by: biweeklyPayment)
        let daysToAdd = periods * 14

        return Calendar.current.date(byAdding: .day, value: daysToAdd, to: startDate)
    }
}

enum DecimalMath {
    /// Returns ceil(lhs / rhs) as an Int, using Decimal-safe math.
    static func divideAndRoundUp(_ lhs: Decimal, by rhs: Decimal) -> Int {
        let lhsNum = NSDecimalNumber(decimal: lhs)
        let rhsNum = NSDecimalNumber(decimal: rhs)

        let quotient = lhsNum.dividing(by: rhsNum)

        let handler = NSDecimalNumberHandler(
            roundingMode: .up,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: true
        )

        let rounded = quotient.rounding(accordingToBehavior: handler)
        return max(0, rounded.intValue)
    }
}