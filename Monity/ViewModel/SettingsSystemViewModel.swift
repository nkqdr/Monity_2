//
//  SettingsSystemViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import Combine

class SettingsSystemViewModel: ItemListViewModel<Transaction> {
    @Published var transactionCategories: [TransactionCategory] = []
    @Published var isWorking: Bool = false
    @Published var registeredTransactions: Int = 0
    @Published var registeredSavingsEntries: Int = 0
    @Published var storageUsedString: String = PersistenceController.shared.getSqliteStoreSize()
    @Published var showFilePicker: Bool = false
    @Published var showInvalidFileAlert: Bool = false
    @Published var importSummary: ImportCSVSummary?
    @Published var csvFileContent: String = "" {
        didSet {
            let rows = csvFileContent.split(whereSeparator: \.isNewline)
            let header: String = String(rows.first ?? "")
            if header == CSVValidHeaders.transactionCSV {
                importSummary = ImportCSVSummary(resourceName: "Transactions", rowsAmount: rows.count-1, rows: rows[1...].map { String($0) })
            } else if header == CSVValidHeaders.savingsCSV {
                importSummary = ImportCSVSummary(resourceName: "Savings", rowsAmount: rows.count-1, rows: rows[1...].map { String($0) })
            } else {
                importSummary = nil
                showInvalidFileAlert.toggle()
            }
        }
    }
    
    private var transactionCategoryCancellable: AnyCancellable?
    
    init() {
        let transactionPublisher = TransactionStorage.shared.items.eraseToAnyPublisher()
        let transactionCategoryPublisher = TransactionCategoryStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: transactionPublisher)
        transactionCategoryCancellable = transactionCategoryPublisher.sink { categories in
            self.transactionCategories = categories
        }
    }
    
    override func onItemsSet() {
        registeredTransactions = items.count
    }
    
    // MARK: - Helper functions
    func importTransactionsCSV(_ rows: [String]) {
        let result = TransactionStorage.shared.add(set: rows)
        if !result {
            showInvalidFileAlert.toggle()
        }
    }
    
    func importSavingsCSV(_ rows: [String]) {
        // TODO: Implement this after defining savings model
    }
    
    // MARK: - Intents
    
    func importCSV() {
        guard let summary = importSummary else {
            return
        }
        DispatchQueue.main.async {
            if summary.resourceName == "Transactions" {
                self.importTransactionsCSV(summary.rows)
            } else if summary.resourceName == "Savings" {
                self.importSavingsCSV(summary.rows)
            }
        }
        // End with this to close the sheet
        importSummary = nil
    }
    
    func deleteAllData() {
        // Delete transaction categories, so that all transactions will be deleted by cascade.
        TransactionCategoryStorage.shared.delete(allIn: transactionCategories)
    }
    
    func exportTransactionsCSV() {
        
    }

    func exportSavingsCSV() {
        
    }
    
    private struct CSVValidHeaders {
        static let transactionCSV: String = "description,amount,date,type,category"
        static let savingsCSV: String = "amount,date,category_name,category_label"
    }
}
