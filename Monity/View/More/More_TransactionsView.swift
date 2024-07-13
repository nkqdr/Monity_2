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

fileprivate struct MonthlyLimitSection: View {
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
        } footer: {
            Text("Establish a monthly budget and aim to stay within your limits.")
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

fileprivate struct TransactionCategoryTile: View {
    @ObservedObject var category: TransactionCategory
    @Binding var categoryToEdit: TransactionCategory?
    @State private var showConfirmationDialog: Bool = false
    
    var body: some View {
        HStack {
            if let icon = category.iconName {
                Image(systemName: icon)
                    .padding(.trailing, 10)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(category.wrappedName)
                Text("Associated transactions: \(category.wrappedTransactionsCount)")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .deleteSwipeAction {
            showConfirmationDialog.toggle()
        }
        .editSwipeAction {
            categoryToEdit = category
        }
        .contextMenu {
            Button {
                categoryToEdit = category
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive) {
                showConfirmationDialog.toggle()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Delete transaction",
            isPresented: $showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut) {
                    TransactionCategoryStorage.main.delete(category)
                }
            }
        } message: {
            Text("Are you sure you want to delete this transaction?")
        }
    }
}

struct More_TransactionsView: View {
    @FetchRequest(
        entity: TransactionCategory.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TransactionCategory.numTransactions, ascending: false)
        ]
    ) private var allCategories: FetchedResults<TransactionCategory>
    @State private var categoryToEdit: TransactionCategory? = nil
    @State private var showAddCategoryForm: Bool = false
    @State var showBudgetWizard: Bool = false
    
    var body: some View {
        List {
            MonthlyLimitSection(showBudgetWizard: $showBudgetWizard)
            Section {
                ForEach(allCategories) { category in
                    TransactionCategoryTile(category: category, categoryToEdit: $categoryToEdit)
                }
            } header: {
                HStack {
                    Text("Categories")
                    Spacer()
                    Button {
                        showAddCategoryForm.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            } footer: {
                Text("These will help you categorize all of your expenses and income")
            }
        }
        .sheet(isPresented: $showBudgetWizard) {
            BudgetWizard()
                .interactiveDismissDisabled()
//                .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $showAddCategoryForm) {
            TransactionCategoryFormView(
                editor: TransactionCategoryEditor()
            )
        }
        .sheet(item: $categoryToEdit) { category in
            TransactionCategoryFormView(
                editor: TransactionCategoryEditor(category: category)
            )
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Settings_TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        More_TransactionsView()
    }
}

