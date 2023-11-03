//
//  SettingsTransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
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

fileprivate struct SetLimitSheet: View {
    @Binding var isPresented: Bool
    @FocusState private var limitInputIsFocussed: Bool
    @State private var tmpMonthlyLimit: Double = UserDefaults.standard.double(forKey: AppStorageKeys.monthlyLimit)
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Budget", value: $tmpMonthlyLimit, format: .customCurrency())
                        .keyboardType(.decimalPad)
                        .focused($limitInputIsFocussed)
                } header: {
                    Text("Monthly budget")
                }
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
                        isPresented.toggle()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel, action: {
                        isPresented.toggle()
                    })
                }
            }
        }
    }
}

fileprivate struct MonthlyLimitSection: View {
    @AppStorage(AppStorageKeys.monthlyLimit) private var monthlyLimit: Double?
    @State private var showingEditAlert: Bool = false
    @State private var showingDeleteConfirmation: Bool = false
    
    private var budgetLevel: BudgetLevel? {
        BudgetLevel.getDetails(for: monthlyLimit ?? -1)
    }
    
    private var monthlyLimitFooter: some View {
        Text("Establish a monthly budget and aim to stay within your limits.")
    }
    
    var body: some View {
        Section(footer: monthlyLimitFooter) {
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
                    showingEditAlert.toggle()
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Delete budget", role: .destructive) {
                    showingDeleteConfirmation.toggle()
                }
                .buttonStyle(.borderless)
            }
        }
        .sheet(isPresented: $showingEditAlert) {
            SetLimitSheet(isPresented: $showingEditAlert)
                .presentationDetents([.height(200)])
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
        .textCase(nil) // To avoid dialogs appearing in all-uppercase
    }
}

struct More_TransactionsView: View {
    @StateObject private var content = SettingsTransactionsViewModel()
    @State private var transactionCategoryForList: TransactionCategory? = nil
    
    var body: some View {
        EditableDeletableItemList(viewModel: content) { create, edit, delete in
            MonthlyLimitSection()
            Section(header: categorySectionHeader(create), footer: categorySectionFooter) {
                ForEach(content.items) { category in
                    EditableDeletableItem(
                        item: category,
                        confirmationTitle: "Are you sure you want to delete \(category.wrappedName)?",
                        confirmationMessage: "\(category.wrappedTransactionsCount) related transactions will be deleted.",
                        onEdit: edit,
                        onDelete: delete) { item in
                            HStack {
                                if let icon = item.iconName {
                                    Image(systemName: icon)
                                        .padding(.trailing, 10)
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                                VStack(alignment: .leading) {
                                    Text(item.wrappedName)
                                    Text("Associated transactions: \(item.wrappedTransactionsCount)")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                }
                            }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            self.transactionCategoryForList = category
                        } label: {
                            Label("Show transactions", systemImage: "list.bullet")
                        }
                        .tint(.mint)
                    }
                }
            }
        } sheetContent: { showAddItemSheet, currentItem in
            TransactionCategoryFormView(
                editor: TransactionCategoryEditor(category: currentItem)
            )
        }
        .sheet(item: $transactionCategoryForList) { val in
            NavigationStack {
                TransactionListPerCategory(category: val, showExpenses: nil)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close", role: .cancel) {
                                transactionCategoryForList = nil
                            }
                        }
                    }
                    .navigationTitle(val.wrappedName)
                    .navigationBarTitleDisplayMode(.large)
            }
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func categorySectionHeader(_ createFunc: @escaping () -> Void) -> some View {
        HStack {
            Text("Categories")
            Spacer()
            Button(action: createFunc) {
                Image(systemName: "plus")
            }
        }
    }
    
    private var categorySectionFooter: some View {
        Text("These will help you categorize all of your expenses and income")
    }
}

struct Settings_TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        More_TransactionsView()
    }
}

