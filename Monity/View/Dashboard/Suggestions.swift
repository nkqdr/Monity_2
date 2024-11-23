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

extension UserDefaults {
    @objc var ignoreBudgetSuggestion: Double {
        get {
            return double(forKey: "ignore_budget_suggestion")
        }
        set {
            set(newValue, forKey: "ignore_budget_suggestion")
        }
    }
}


class CUSUMBudgetTracker: ObservableObject {
    ///S^{+} := 0
    ///S^{-} := 0
    ///for t := 1, 2, 3, ...:
    ///    S^{+} := max(S^{+} + x_t - k, 0)
    ///    S^{-} := min(S^{-} + x_t + k, 0)
    ///    if (S^{+} > h or S^{-}  < -h):
    ///        Recommend budget change
    ///        S^{+} := 0
    ///        S^{-} := 0
    ///
    @Published var suggestedBudget: Double = 0
    @Published var currentBudget: Double = 0
    @Published var suggestNewBudget: Bool = false
    @Published var ignoreBudgetSuggestionDate: Date? = nil
    private var transactions: [Transaction] = []
    private var expensesCancellable: AnyCancellable?
    private var expensesFetchController: TransactionFetchController
    private var ignoreBudgetSuggestionCancellable: AnyCancellable?
    
    init() {
        self.currentBudget = UserDefaults.standard.double(forKey: AppStorageKeys.monthlyLimit)
        
        let startOfMonth: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let startOfMonthDate = Calendar.current.date(from: startOfMonth)!
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: startOfMonthDate)!
        
        let controller = TransactionFetchController(
            isExpense: true,
            startDate: sixMonthsAgo,
            endDate: startOfMonthDate
        )
        self.expensesFetchController = controller
        
        let ignoreSuggestionPublisher = UserDefaults.standard.publisher(for: \.ignoreBudgetSuggestion).eraseToAnyPublisher()
        self.ignoreBudgetSuggestionCancellable = ignoreSuggestionPublisher.sink { newValue in
            let ignoreSuggestionDate = Date(timeIntervalSince1970: newValue)
            self.ignoreBudgetSuggestionDate = ignoreSuggestionDate
        }
        
        let transactionsPublisher = self.expensesFetchController.items.eraseToAnyPublisher()
        self.expensesCancellable = transactionsPublisher.sink { transactions in
            self.transactions = transactions
            self.calculateBudgetSuggestion(transactions, currentBudget: self.currentBudget)
        }
    }
    
    private func roundToNextQuarter(_ value: Double) -> Double {
        // E.g. let value be 1654.9
        let valueShiftedToDecimal = value / 100 // = 16.549
        let nextQuarterValue = ceil(valueShiftedToDecimal * 4) / 4 // = 16.75
        let res = nextQuarterValue * 100 // = 1675.0
        return res
    }
    
    private func calculateMonthlyExpenses(_ transactions: [Transaction]) -> [Double] {
        // Group transactions by month and sum up their amounts within each month
        let groupedTransactions = transactions.grouped(by: { t in
            let date = t.wrappedDate
            let comps = Calendar.current.dateComponents([.year, .month], from: date)
            return comps
        })
        let monthlyExpenses = groupedTransactions.mapValues {
            $0.map(\.amount).reduce(0, +)
        }
        return Array(monthlyExpenses.values)
    }
    
    private func calculateMeanAndStandardDeviation(_ expenses: [Double]) -> (mean: Double, standardDeviation: Double) {
        var mean = 0.0
        var sddev = 0.0
        vDSP_normalizeD(expenses, 1, nil, 1, &mean, &sddev, vDSP_Length(expenses.count))
        sddev *= sqrt(Double(expenses.count)/Double(expenses.count - 1))
        return (mean: mean, standardDeviation: sddev)
    }
    
    private func calculateBudgetSuggestion(_ transactions: [Transaction], currentBudget: Double) {
        let expensesList = self.calculateMonthlyExpenses(transactions)
        let (mean, sddev) = self.calculateMeanAndStandardDeviation(expensesList)
        print("Std: \(sddev), Mean: \(mean)")
        
        let h = 5.0 * sddev
        let k = 0.2 * sddev
        let x = expensesList.map {$0 - currentBudget}
        print("h: \(h), k: \(k), x: (\(x))")
        self.suggestNewBudget = false
        var s_plus = 0.0
        var s_minus = 0.0
        for x_i in x {
            s_plus = max(s_plus + x_i - k, 0.0)
            s_minus = min(s_minus + x_i + k, 0.0)
            print("x: \(x_i), s_plus: \(s_plus), s_minus: \(s_minus)")
            if s_plus > h || s_minus < -h {
                print("HIT")
                self.suggestNewBudget = true
                self.suggestedBudget = self.roundToNextQuarter(vDSP.mean(expensesList))
                break
            }
        }
    }
    
    public func budgetDidChange(to newBudget: Double) {
        self.currentBudget = newBudget
        self.calculateBudgetSuggestion(self.transactions, currentBudget: self.currentBudget)
        self.handleIgnore() // Make sure that we start the CUSUM algorithm from the current date
    }
    
    public func handleIgnore() {
        UserDefaults.standard.ignoreBudgetSuggestion = Date().timeIntervalSince1970
    }
}


struct Suggestions: View {
    @State var showNotification: Bool = false
    @State var showBudgetWizard: Bool = false
    @ObservedObject var viewModel: CUSUMBudgetTracker = .init()
    
    var ignoreBudgetSuggestions: Bool {
        guard let ignoreBudgetStoredDate = viewModel.ignoreBudgetSuggestionDate else { return false }
        let nowComps = Calendar.current.dateComponents([.year, .month], from: Date())
        let now = Calendar.current.date(from: nowComps)!
        // Ignore the suggestions if the user clicked "ignore" within the three months
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: now)!
        return threeMonthsAgo < ignoreBudgetStoredDate
    }
    
    @ViewBuilder
    private func SuggestionNotification() -> some View {
        VStack(alignment: .leading) {
            Group {
                Text("💰 ") + Text("It's time to rethink your budget")
            }
            .font(.headline)
            .padding(.bottom, 4)
            Text("Your current budget is set at \(viewModel.currentBudget.formatted(.customCurrency())). To better align with your financial habits, we recommend adjusting it to \(viewModel.suggestedBudget.formatted(.customCurrency())).")
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.bottom, 16)
                HStack {
                    Spacer()
                    Button("Ignore") {
                        withAnimation {
                            showNotification = false
                        }
                        viewModel.handleIgnore()
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
                SetLimitSheet(budgetSuggestion: viewModel.suggestedBudget) { newBudgetValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showNotification = false
                        }
                        viewModel.budgetDidChange(to: newBudgetValue)
                    }
                }
                .presentationDetents([.height(200)])
            }
            .padding(.bottom, 5)
    }
    
    var body: some View {
        if viewModel.suggestNewBudget {
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
