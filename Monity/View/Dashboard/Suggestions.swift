//
//  Suggestions.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.24.
//

import SwiftUI

import Foundation
import Combine
import Accelerate

class BudgetSuggestionViewModel: ObservableObject {
    @Published var averageExpensesInLast4Months: Double = 0 {
        didSet {
            setSuggestedBudget()
        }
    }
    @Published var suggestedBudget: Double? = nil
    @Published var currentBudget: Double = 0
    private var expensesCancellable: AnyCancellable?
    private var expensesFetchController: TransactionFetchController
    
    init() {
        let nowComponents: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let nowDate = Calendar.current.date(from: nowComponents)!
        let fourMonthsAgo = Calendar.current.date(byAdding: .month, value: -4, to: nowDate)!
        let controller = TransactionFetchController(isExpense: true, startDate: fourMonthsAgo, endDate: nowDate)
        self.expensesFetchController = controller
        let publisher = self.expensesFetchController.items.eraseToAnyPublisher()
        
        self.expensesCancellable = publisher.sink { transactions in
            // Group transactions by month and sum up their amounts within each month
            let groupedTransactions = transactions.grouped(by: { t in
                let date = t.wrappedDate
                let comps = Calendar.current.dateComponents([.year, .month], from: date)
                return comps
            })
            let monthlyExpenses = groupedTransactions.mapValues {
                $0.map(\.amount).reduce(0, +)
            }
            // sort by the date key
            let sortedExpenses = monthlyExpenses.sorted {
                $0.key.year! <= $1.key.year! && $0.key.month! <= $1.key.month!
            }.map(\.value)
            print(sortedExpenses)
            self.averageExpensesInLast4Months = vDSP.mean(sortedExpenses)
        }
        self.budgetDidChange()
    }
    
    private func roundToNextQuarter(_ value: Double) -> Double {
        // E.g. let value be 1654.9
        let valueShiftedToDecimal = value / 100 // = 16.549
        let nextQuarterValue = ceil(valueShiftedToDecimal * 4) / 4 // = 16.75
        let res = nextQuarterValue * 100 // = 1675.0
        return res
    }
    
    public func setSuggestedBudget(validDiscrepancy: Double = 0.1) {
        // If the average expenses in the last four months is outside of current budget
        // +- {validDiscrepancy}% of the current budget, suggest the budget to be the average expenses of
        // the past four months rounded to a value that ends with 0, 25, 50, or 75.
        let upperBound = currentBudget * (1 + validDiscrepancy)
        let lowerBound = currentBudget * (1 - validDiscrepancy)
        if (lowerBound <= averageExpensesInLast4Months && averageExpensesInLast4Months <= upperBound) {
            self.suggestedBudget = nil
            return
        }
        self.suggestedBudget = self.roundToNextQuarter(self.averageExpensesInLast4Months)
    }
    
    public func budgetDidChange() {
        self.currentBudget = UserDefaults.standard.double(forKey: AppStorageKeys.monthlyLimit)
        self.setSuggestedBudget()
    }
}

struct Suggestions: View {
    @State var showNotification: Bool = false
    @ObservedObject var viewModel: BudgetSuggestionViewModel = .init()
    @AppStorage(
        AppStorageKeys.ignoreBudgetSuggestionsDate
    ) private var ignoreBudgetSuggestionsDouble: Double = 0
    @State var showBudgetWizard: Bool = false
    
    var ignoreBudgetStoredDate: Date? {
        if ignoreBudgetSuggestionsDouble == 0 {
            return nil
        }
        return Date(timeIntervalSince1970: ignoreBudgetSuggestionsDouble)
    }
    
    var ignoreBudgetSuggestions: Bool {
        guard let ignoreBudgetStoredDate else { return false }
        // Ignore the suggestions if the user clicked "ignore" within the last month
        let oneMonthAgo = Date().addingTimeInterval(-60 * 60 * 24 * 30)
        return oneMonthAgo < ignoreBudgetStoredDate
    }
    
    @ViewBuilder
    private func SuggestionNotification() -> some View {
        VStack(alignment: .leading) {
            Group {
                Text("💰 ") + Text("It's time to rethink your budget")
            }
            .font(.headline)
            .padding(.bottom, 4)
            Text("You spent \(viewModel.averageExpensesInLast4Months.formatted(.customCurrency())) on average in the past four months while your budget is \(viewModel.currentBudget.formatted(.customCurrency()))")
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.bottom, 16)
                HStack {
                    Spacer()
                    Button("Ignore") {
                        withAnimation {
                            showNotification = false
                        }
                        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: AppStorageKeys.ignoreBudgetSuggestionsDate)
                    }
                    .buttonStyle(.bordered)
                    Button("Adjust Budget") {
                        showBudgetWizard.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            .sheet(isPresented: $showBudgetWizard) {
                SetLimitSheet(budgetSuggestion: viewModel.suggestedBudget) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showNotification = false
                            viewModel.budgetDidChange()
                        }
                    }
                }
                .presentationDetents([.height(200)])
            }
            .padding(.bottom, 5)
    }
    
    var body: some View {
        if viewModel.suggestedBudget != nil {
            if !self.ignoreBudgetSuggestions {
                VStack {
                    if showNotification {
                        SuggestionNotification()
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            self.showNotification = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
