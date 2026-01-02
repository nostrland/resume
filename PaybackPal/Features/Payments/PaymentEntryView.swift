import SwiftUI

struct PaymentEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var repository: PaymentsRepository
    
    @State private var amountText: String = ""
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Text("Enter Payment Amount")
                    .font(DesignSystem.Typography.title)
                    .padding(.top, DesignSystem.Spacing.lg)
                
                TextField("$0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(DesignSystem.Typography.largeBalance)
                    .multilineTextAlignment(.center)
                    .focused($isAmountFocused)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .onAppear {
                        isAmountFocused = true
                    }
                
                Spacer()
                
                Button {
                    savePayment()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.lg)
                .disabled(amountText.isEmpty || parseAmount() <= 0)
            }
            .navigationTitle("Custom Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func parseAmount() -> Decimal {
        let cleaned = amountText.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Decimal(string: cleaned) ?? 0
    }
    
    private func savePayment() {
        let amount = parseAmount()
        guard amount > 0 else { return }
        
        let payment = Payment(amount: amount)
        repository.addPayment(payment)
        dismiss()
    }
}

