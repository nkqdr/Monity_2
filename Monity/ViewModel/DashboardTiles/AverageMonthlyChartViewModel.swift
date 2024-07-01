//
//  AverageMonthlyChartViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import Foundation
import Combine

class AverageMonthlyChartViewModel: ObservableObject {
    static let shared: AverageMonthlyChartViewModel = AverageMonthlyChartViewModel()
    @Published var showingExpenses: Bool = true
    @Published var expenseCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    @Published var incomeCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    
    var retroDataPoints: [CategoryRetroDataPoint] {
        showingExpenses ? expenseCategoryRetroDataPoints : incomeCategoryRetroDataPoints
    }
    
    var transactionCategories: [TransactionCategory] = []

    private var transactionCategoryCancellable: AnyCancellable?
    
    init() {
        let categoryPublisher = TransactionCategoryFetchController.all.items.eraseToAnyPublisher()
        transactionCategoryCancellable = categoryPublisher.sink { categories in
            self.transactionCategories = categories
            self.expenseCategoryRetroDataPoints = self.updateFilteredRetroDataPoints(isExpense: true)
            self.incomeCategoryRetroDataPoints = self.updateFilteredRetroDataPoints(isExpense: false)
        }
    }
    
    private func updateFilteredRetroDataPoints(isExpense: Bool) -> [CategoryRetroDataPoint] {
        let dataPoints: [CategoryRetroDataPoint] = transactionCategories.map {
            CategoryRetroDataPoint(category: $0, timeframe: .pastYear, isForExpenses: isExpense)
        }
        return dataPoints.filter { $0.total > 0 } .sorted {
            $0.total > $1.total
        }
    }
}
