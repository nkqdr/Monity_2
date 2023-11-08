//
//  SettingsSystemViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import Combine

class CSVImporter: ObservableObject {
    @Published var importSummary: ImportCSVSummary?
    @Published var importHasError: Bool = false
    @Published var isReading: Bool = false
    @Published var showDocumentPicker: Bool = false
    @Published var importProgress: Double = 0
    @Published var csvFileContent: String = "" {
        didSet {
            if !csvFileContent.isEmpty {
                handleContentChange()
            }
        }
    }
    @Published var showInvalidFileAlert: Bool = false
    
    
    // MARK: - Helper functions
    
    func importTransactionsCSV(_ rows: [String]) {
        let result = TransactionStorage.main.add(set: rows)
        if !result {
            showInvalidFileAlert.toggle()
        }
    }
    
    func importSavingsCSV(_ rows: [String]) {
        let result = SavingStorage.main.add(set: rows)
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
    
    func handleContentChange() {
        isReading = true
        importSummary = nil
        DispatchQueue.global(qos: .userInteractive).async {
            let rows = self.csvFileContent.split(whereSeparator: \.isNewline)
            let header: CSVValidHeaders? = CSVValidHeaders.fromValue(String(rows.first ?? ""))
            guard let header else {
                DispatchQueue.main.async {
                    self.importSummary = nil
                    self.importHasError = true
                    self.showInvalidFileAlert.toggle()
                    self.isReading = false
                }
                return
            }
            DispatchQueue.main.async {
                self.importSummary = ImportCSVSummary(resource: header, rowsAmount: rows.count-1, rows: rows[1...].map { String($0) })
                self.isReading = false
                self.importHasError = false
            }
        }
    }
    
    // MARK: - Intents
    
    func importCSV(dismissFunc: @escaping () -> Void) {
        guard let summary = importSummary else {
            return
        }
        DispatchQueue.main.async {
            self.importProgress = 0
            if summary.resourceName == "Transactions" {
                self.importTransactionsCSV(summary.rows)
            } else if summary.resourceName == "Savings" {
                self.importSavingsCSV(summary.rows)
            } else if summary.resourceName == "Recurring expenses" {
                self.importRecurringTransactionsCSV(summary.rows)
            }
            Haptics.shared.notify(.success)
            self.importProgress = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                dismissFunc()
            }
        }
    }
    
}

class SettingsSystemViewModel: ObservableObject {
    @Published var isWorking: Bool = false
    @Published var storageUsedString: String = PersistenceController.shared.getSqliteStoreSize()
    @Published var showFilePicker: Bool = false
    @Published var totalTransactionCount: Int = 0
    @Published var totalSavingsCount: Int = 0
    @Published var totalRecurringTransactionCount: Int = 0
    
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
        
        let savingsPublisher = SavingsFetchController.all.items.eraseToAnyPublisher()
        self.savingsCancellable = savingsPublisher.sink { values in
            self.totalSavingsCount = values.count
        }
    }
    
    // MARK: - Intents
    
    func deleteTransactionData() {
        TransactionStorage.main.deleteAll()
        TransactionCategoryStorage.main.deleteAll()
    }
    
    func deleteSavingsData() {
        SavingsCategoryStorage.main.deleteAll()
        SavingStorage.main.deleteAll()
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
