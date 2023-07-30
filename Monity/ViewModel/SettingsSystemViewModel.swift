//
//  SettingsSystemViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import Combine

class SettingsSystemViewModel: ObservableObject {
    @Published var isWorking: Bool = false
    @Published var storageUsedString: String = PersistenceController.shared.getSqliteStoreSize()
    @Published var showFilePicker: Bool = false
    @Published var showInvalidFileAlert: Bool = false
    @Published var importSummary: ImportCSVSummary?
    @Published var totalTransactionCount: Int = 0
    @Published var totalSavingsCount: Int = 0
    @Published var totalRecurringTransactionCount: Int = 0
    @Published var csvFileContent: String = "" {
        didSet {
            let rows = csvFileContent.split(whereSeparator: \.isNewline)
            let header: CSVValidHeaders? = CSVValidHeaders.fromValue(String(rows.first ?? ""))
            guard let header else {
                importSummary = nil
                showInvalidFileAlert.toggle()
                return
            }
            importSummary = ImportCSVSummary(resource: header, rowsAmount: rows.count-1, rows: rows[1...].map { String($0) })
        }
    }
    
    private var transactionCancellable: AnyCancellable?
    private var recurringTransactionCancellable: AnyCancellable?
    private var savingsCancellable: AnyCancellable?
    
    init() {
        let transactionPublisher = TransactionFetchController.all.items.eraseToAnyPublisher()
        self.transactionCancellable = transactionPublisher.sink { values in
            self.totalTransactionCount = values.count
        }
        
        let recurringTransactionPublisher = RecurringTransactionFetchController.all.items.eraseToAnyPublisher()
        self.recurringTransactionCancellable = recurringTransactionPublisher.sink { values in
            self.totalRecurringTransactionCount = values.count
        }
        
        let savingsPublisher = SavingStorage.shared.items.eraseToAnyPublisher()
        self.savingsCancellable = savingsPublisher.sink { values in
            self.totalSavingsCount = values.count
        }
    }
    
    // MARK: - Helper functions
    func importTransactionsCSV(_ rows: [String]) {
        let result = TransactionStorage.main.add(set: rows)
        if !result {
            showInvalidFileAlert.toggle()
        }
    }
    
    func importSavingsCSV(_ rows: [String]) {
        let result = SavingStorage.shared.add(set: rows)
        if !result {
            showInvalidFileAlert.toggle()
        }
    }
    
    func importRecurringTransactionsCSV(_ rows: [String]) {
        let result = RecurringTransactionStorage.main.add(set: rows)
        if !result {
            showInvalidFileAlert.toggle()
        }
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
            } else if summary.resourceName == "Recurring expenses" {
                self.importRecurringTransactionsCSV(summary.rows)
            }
        }
        // End with this to close the sheet
        importSummary = nil
    }
    
    func deleteTransactionData() {
        TransactionStorage.main.deleteAll()
        TransactionCategoryStorage.main.deleteAll()
    }
    
    func deleteSavingsData() {
        SavingsCategoryStorage.shared.deleteAll()
        SavingStorage.shared.deleteAll()
    }
    
    func deleteRecurringTransactionData() {
        RecurringTransactionStorage.main.deleteAll()
    }
    
    func deleteAllData() {
        deleteTransactionData()
        deleteSavingsData()
        deleteRecurringTransactionData()
    }
}
