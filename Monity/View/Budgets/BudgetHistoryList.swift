//
//  BudgetHistoryList.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import SwiftUI

fileprivate struct BudgetListTile: View {
    @ObservedObject var budget: Budget
    @State private var showConfirmationDialog: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Valid from: ")
                    .foregroundStyle(.secondary)
                Text(budget.wrappedValidFrom, format: .dateTime)
            }
            Spacer()
            if budget.amount != 0 {
                Text(budget.amount, format: .customCurrency())
                    .tintedBackground(.green)
            } else {
                Text("No budget")
                    .tintedBackground(.secondary)
            }
        }
        .deleteSwipeAction {
            showConfirmationDialog.toggle()
        }
        .confirmationDialog("Delete Budget", isPresented: $showConfirmationDialog) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                withAnimation {
                    BudgetStorage.main.delete(budget)
                }
            }
        } message: {
            Text("Are you sure that you want to delete this budget? \nThis cannot be undone.")
        }
    }
}

struct BudgetHistoryList: View {
    @FetchRequest private var allBudgets: FetchedResults<Budget>
    var category: TransactionCategory?
    
    init(category: TransactionCategory? = nil) {
        var predicate: NSPredicate
        if let category {
            predicate = NSPredicate(format: "category == %@", category)
        } else {
            predicate = NSPredicate(format: "category == NULL")
        }
        self._allBudgets = FetchRequest(
            entity: Budget.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Budget.validFrom, ascending: false)
            ],
            predicate: predicate
        )
        self.category = category
    }
    
    @ViewBuilder var listView: some View {
        List {
            ForEach(allBudgets) { budget in
                BudgetListTile(budget: budget)
            }
        }
    }
    
    @ViewBuilder var emptyView: some View {
        VStack {
            Spacer()
            Text("You haven't defined a budget for this category yet.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding()
            Spacer()
        }
    }
    
    var body: some View {
        Group {
            if allBudgets.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .navigationTitle("Budget history")
    }
}

#Preview {
    BudgetHistoryList()
}
