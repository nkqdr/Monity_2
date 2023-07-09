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
    
    func deleteTransactionData() {
        TransactionCategoryStorage.main.deleteAll()
        TransactionStorage.main.deleteAll()
    }
    
    func deleteSavingsData() {
        SavingsCategoryStorage.shared.deleteAll()
        SavingStorage.shared.deleteAll()
    }
    
    func deleteAllData() {
        // Delete categories, so that all items will be deleted by cascade.
        deleteTransactionData()
        deleteSavingsData()
    }
}
