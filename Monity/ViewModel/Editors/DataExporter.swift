//
//  DataExporter.swift
//  Monity
//
//  Created by Niklas Kuder on 30.10.22.
//

import Foundation

class DataExporter: ObservableObject {
    @Published var exportTransactions: Bool = false
    @Published var exportSavings: Bool = false
    @Published var exportRecurringTransactions: Bool = false
    @Published var exportHasErrors: Bool = false
    @Published var exportWasSuccessful: Bool = false
    
    var disableExportButton: Bool {
        !(exportSavings || exportTransactions || exportRecurringTransactions)
    }
    
    private func getCSVExportString(for list: [CSVRepresentable], headers: String) -> String {
        var exportString: String = headers + "\n"
        for item in list {
            exportString += item.commaSeparatedString + "\n"
        }
        return exportString
    }
    
    private func getFilenameWithPrefix(filename: String) -> String {
        let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        return filename + "-" + "\(date.year ?? 0)-\(date.month ?? 0)-\(date.day ?? 0)-\(date.hour ?? 0)-\(date.minute ?? 0)-\(date.second ?? 0)" + ".csv"
    }
    
    private func writeStringToDisk(content: String, filename: String) {
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            exportWasSuccessful = true
        } catch {
            exportHasErrors = true
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func handleExportTransactions() {
        let transactions = getCSVExportString(for: TransactionFetchController.all.items.value, headers: CSVValidHeaders.transactionCSV)
        let transactionsFilename = getFilenameWithPrefix(filename: "transactions")
        writeStringToDisk(content: transactions, filename: transactionsFilename)
    }
    
    private func handleExportSavings() {
        let savings = getCSVExportString(for: SavingStorage.shared.items.value, headers: CSVValidHeaders.savingsCSV)
        let savingsFilename = getFilenameWithPrefix(filename: "savings")
        writeStringToDisk(content: savings, filename: savingsFilename)
    }
    
    private func handleExportRecurringTransactions() {
        let recurringTransactions = getCSVExportString(for: RecurringTransactionFetchController.all.items.value, headers: CSVValidHeaders.recurringTransactionCSV)
        let recurringTransactionsFilename = getFilenameWithPrefix(filename: "recurring_transactions")
        writeStringToDisk(content: recurringTransactions, filename: recurringTransactionsFilename)
    }
    
    // MARK: - Intents
    func triggerExport() {
        if exportSavings {
            handleExportSavings()
        }
        if exportTransactions {
            handleExportTransactions()
        }
        if exportRecurringTransactions {
            handleExportRecurringTransactions()
        }
    }
}
