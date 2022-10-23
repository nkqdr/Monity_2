//
//  TransactionCategorySummaryView.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import SwiftUI

struct TransactionCategorySummaryView: View {
    @State var showEditTransactionView: Bool = false
    @ObservedObject var content: TransactionsCategorySummaryViewModel
    var category: TransactionCategory
    
    init(category: TransactionCategory) {
        self.content = TransactionsCategorySummaryViewModel(category: category)
        self.category = category
    }
    
    var body: some View {
        TransactionsList(showAddTransactionView: $showEditTransactionView, transactionsByDate: content.transactionsByDate, dateFormat: .dateTime.year().month())
            .navigationTitle(category.wrappedName)
    }
}

struct TransactionSummaryView_Previews: PreviewProvider {
    static func generateData() -> TransactionCategory {
        let c = TransactionCategory(context: PersistenceController.preview.container.viewContext)
        c.name = "Test Category"
        c.id = UUID()
        let transaction = Transaction(context: PersistenceController.preview.container.viewContext)
        transaction.id = UUID()
        transaction.category = c
        transaction.isExpense = true
        transaction.date = Date()
        transaction.amount = 154.5
        return c
    }
    
    static var previews: some View {
        let c = generateData()
        TransactionCategorySummaryView(category: c)
    }
}
