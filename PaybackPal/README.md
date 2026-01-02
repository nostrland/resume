# PaybackPal

A personal debt tracking app built with SwiftUI for iOS 17+.

## Overview

PaybackPal helps you track your debt payments, estimate payoff dates, and schedule reminders for biweekly paydays. The app starts with an initial balance of $5,055.00 and allows you to record payments, view your progress, and get notified when it's time to make a payment.

## Features

- **Balance Tracking**: View your current owed balance prominently on the dashboard
- **Quick Payments**: Record payments with preset amounts ($20, $50, $100, $200) or custom amounts
- **Payoff Estimation**: Calculate estimated payoff date based on biweekly payment amounts
- **Payment History**: View recent payments with swipe-to-delete functionality
- **Reminders**: Schedule local notifications for biweekly payday reminders

## How to Run

1. Open `PaybackPal.xcodeproj` in Xcode 14.0 or later
2. Select a simulator or connected device (iOS 17.0+)
3. Build and run (⌘R)

## Project Structure

```
PaybackPal/
├── App/
│   └── PaybackPalApp.swift          # App entry point
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift       # Main screen UI
│   │   └── DashboardViewModel.swift  # Dashboard business logic
│   ├── Payments/
│   │   └── PaymentEntryView.swift    # Custom payment entry sheet
│   └── Reminders/
│       └── ReminderScheduler.swift   # Local notification scheduling
├── Models/
│   ├── Payment.swift                 # Payment data model
│   └── DebtData.swift                # Debt state model
├── Persistence/
│   └── PaymentsRepository.swift      # UserDefaults-based storage
├── Utilities/
│   ├── CurrencyFormatter.swift       # Currency formatting
│   └── DateHelpers.swift             # Payday calculation utilities
└── DesignSystem/
    └── DesignSystem.swift            # Typography, spacing, colors
```

## Payoff Estimation Logic

The app estimates your payoff date using the following logic:

1. **Current Balance**: The remaining debt after all recorded payments
2. **Biweekly Payment**: The amount you set on the slider (paid every other Wednesday)
3. **Next Payday**: Calculates the next upcoming Wednesday, then every 14 days after
4. **Estimation**: Divides the current balance by the biweekly payment amount to determine the number of payment periods needed

**Formula**: `Payoff Date = Next Payday + (Balance / Biweekly Payment) × 14 days`

If the slider is set to $0, no estimate is shown. The estimate updates in real-time as you adjust the slider or add payments.

## Data Persistence

All data is stored locally using `UserDefaults` with Codable encoding:
- Initial debt amount ($5,055.00)
- List of all payments (amount, date, ID)
- Paycheck payment amount (slider value)

Data persists between app launches automatically.

## Architecture

- **MVVM Pattern**: ViewModels handle business logic, Views are declarative
- **ObservableObject**: Repository and ViewModels use `@Published` for reactive updates
- **No Dependencies**: Pure Swift/SwiftUI implementation
- **Accessibility**: Uses Dynamic Type friendly fonts and large tappable areas

## Requirements

- iOS 17.0+
- Xcode 14.0+
- Swift 5.9+

## License

This is a personal project for educational purposes.

