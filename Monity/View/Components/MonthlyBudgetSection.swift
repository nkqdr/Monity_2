//
//  MonthlyBudgetSection.swift
//  Monity
//
//  Created by Niklas Kuder on 11.04.25.
//
import SwiftUI

fileprivate struct BudgetLevel {
    var title: LocalizedStringKey
    var emoji: String
    var description: LocalizedStringKey
    var rangeMin: Int
    var rangeMax: Int
    
    static func getDetails(for amount: Double) -> BudgetLevel? {
        let lowerAmount = Int(floor(amount))
        return budgetLevels.first(where: { $0.rangeMin <= lowerAmount && lowerAmount < $0.rangeMax})
    }
}

fileprivate let budgetLevels: [BudgetLevel] = [
    BudgetLevel(
        title: "Smart Saver",
        emoji: "💸",
        description: "Mastering the art of saving and shining bright! Low expenses, high savings!",
        rangeMin: 0, rangeMax: 500),
    BudgetLevel(
        title: "Thrifty Achiever",
        emoji: "🎩",
        description: "Making every penny count and managing expenses wisely. Spending smartly, saving cleverly!",
        rangeMin: 500, rangeMax: 1000),
    BudgetLevel(
        title: "Wealth Builder",
        emoji: "💵",
        description:  "Turning financial dreams into reality without breaking the bank. Moderate expenses, maximum aspirations!",
        rangeMin: 1000, rangeMax: 2000),
    BudgetLevel(
        title: "Prosperity Pioneer",
        emoji: "🌟",
        description: "Navigating wealth and expenses with grace. Living comfortably, dreaming extravagantly!",
        rangeMin: 2000, rangeMax: 3000),
    BudgetLevel(
        title: "Cash Champion",
        emoji: "👑",
        description: "Swimming in money and still knowing the value! Living a life of luxury, with expenses as big as diamonds and a bank balance as deep as the ocean!",
        rangeMin: 3000, rangeMax: 5000),
    BudgetLevel(
        title: "Platinum Prestige",
        emoji: "🏰",
        description: "Living in opulence without financial strain. Opulent expenses, grandeur on a budget!",
        rangeMin: 5000, rangeMax: 10000),
    BudgetLevel(
        title: "Billionaire Luminary",
        emoji: "💎",
        description: "Building an empire of wealth and dreams. Sky's the limit for expenses, bank balance reaching for the stars!",
        rangeMin: 10000, rangeMax: Int.max),
]

struct SetLimitSheet: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var limitInputIsFocussed: Bool
    @State private var tmpMonthlyLimit: Double = UserDefaults.standard.double(forKey: AppStorageKeys.monthlyLimit)
    private var budgetSuggestion: Double?
    private var onLimitSet: (Double) -> Void = { _ in }
    
    init(budgetSuggestion: Double? = nil, onLimitSet: @escaping (Double) -> Void = {_ in }) {
        self.budgetSuggestion = budgetSuggestion
        self.onLimitSet = onLimitSet
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    CurrencyInputField(value: $tmpMonthlyLimit)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.green)
                        .focused($limitInputIsFocussed)
                } header: {
                    Text("Monthly budget")
                } footer: {
                    if let suggestion = self.budgetSuggestion {
                        Text("Suggested budget: ") + Text(suggestion, format: .customCurrency())
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .onAppear {
                limitInputIsFocussed = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        withAnimation {
                            UserDefaults.standard.set(tmpMonthlyLimit, forKey: AppStorageKeys.monthlyLimit)
                        }
                        self.onLimitSet(tmpMonthlyLimit)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel, action: {
                        dismiss()
                    })
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        limitInputIsFocussed = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}

struct MonthlyBudgetSection: View {
    @Binding var showBudgetWizard: Bool
    @AppStorage(AppStorageKeys.monthlyLimit) private var monthlyLimit: Double?
    @State private var showingDeleteConfirmation: Bool = false
    
    private var budgetLevel: BudgetLevel? {
        BudgetLevel.getDetails(for: monthlyLimit ?? -1)
    }
    
    var body: some View {
        Section {
            if let budgetLevel {
                HStack(alignment: .top) {
                    Text(budgetLevel.emoji)
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(budgetLevel.title).font(.headline.bold())
                        Text(budgetLevel.description).font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            HStack {
                Text("Your monthly budget:")
                Spacer()
                if let limit = monthlyLimit {
                    Text(limit, format: .customCurrency())
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                } else {
                    Text("-")
                        .foregroundColor(.gray)
                }
            }
            HStack {
                Button("Change budget") {
                    showBudgetWizard.toggle()
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Delete budget", role: .destructive) {
                    showingDeleteConfirmation.toggle()
                }
                .buttonStyle(.borderless)
            }
        } header: {
            Text("Budget")
        } 
        .confirmationDialog("Delete monthly budget", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut) {
                    UserDefaults.standard.removeObject(forKey: AppStorageKeys.monthlyLimit)
                }
            }
        } message: {
            Text("This has no effect on your stored transactions.")
        }
    }
}
