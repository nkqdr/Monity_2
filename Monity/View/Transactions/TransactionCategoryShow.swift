//
//  TransactionCategoryShow.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import SwiftUI

struct TransactionCategoryShow: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var totalExpenseRetro: CategoryRetroDataPoint
    @ObservedObject private var totalIncomeRetro: CategoryRetroDataPoint
    @State private var showEditSheet: Bool = false
    @State private var showConfirmationDialog: Bool = false
    var category: TransactionCategory
    var showExpenses: Bool?

    var color: Color {
        guard let showExpenses else {
            return .primary
        }
        return showExpenses ? .red : .green
    }

    init(category: TransactionCategory, showExpenses: Bool?) {
        self._totalExpenseRetro = ObservedObject(
            wrappedValue: CategoryRetroDataPoint(
                category: category, timeframe: .total, isForExpenses: true
            )
        )
        self._totalIncomeRetro = ObservedObject(
            wrappedValue: CategoryRetroDataPoint(
                category: category, timeframe: .total, isForExpenses: false
            )
        )
        self.category = category
        self.showExpenses = showExpenses
    }

    var body: some View {
        List {
            Text("Associated transactions: \(Int(category.numTransactions))")
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .foregroundStyle(.secondary)
                .font(.callout)
            if totalExpenseRetro.total > 0 {
                Section {
                    VStack {
                        ExpenseBarChartWithHeader(
                            category: category, isExpense: true, color: .red, alwaysShowYmarks: false
                        )
                        .frame(minHeight: 180)
                        .padding(.vertical)
                    }
                    HStack {
                        Text("Total").foregroundStyle(.secondary)
                        Spacer()
                        Text(totalExpenseRetro.total, format: .customCurrency())
                    }
                    HStack {
                        Text("Average per month").foregroundStyle(.secondary)
                        Spacer()
                        Text(totalExpenseRetro.averagePerMonth, format: .customCurrency())
                    }
                } header: {
                    Text("Expenses")
                }
            }

            if totalIncomeRetro.total > 0 {
                Section {
                    VStack {
                        ExpenseBarChartWithHeader(
                            category: category, isExpense: false, color: .green, alwaysShowYmarks: false
                        )
                        .frame(minHeight: 180)
                        .padding(.vertical)
                    }
                    HStack {
                        Text("Total").foregroundStyle(.secondary)
                        Spacer()
                        Text(totalIncomeRetro.total, format: .customCurrency())
                    }
                    HStack {
                        Text("Average per month").foregroundStyle(.secondary)
                        Spacer()
                        Text(totalIncomeRetro.averagePerMonth, format: .customCurrency())
                    }
                } header: {
                    Text("income.plural")
                }
            }

            Section {
                NavigationLink("All transactions", destination: TransactionListPerCategory(category: category, showExpenses: nil)
                        .navigationBarTitleDisplayMode(.inline)
                        .environment(\.showTransactionCategoryOption, false)
                )
            }
        }
        .navigationTitle(category.wrappedName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditSheet.toggle()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Divider()
                    Button(role: .destructive) {
                        showConfirmationDialog.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            TransactionCategoryForm(
                editor: TransactionCategoryEditor(category: category)
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
        }
        .confirmationDialog(
            "Delete category",
            isPresented: $showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut) {
                    dismiss()
                    TransactionCategoryStorage.main.delete(category)
                }
            }
        } message: {
            Text("Are you sure you want to delete \(category.wrappedName)?") + Text("\n") +
            Text("\(Int(category.numTransactions)) transactions will be lost.")
        }
    }
}
