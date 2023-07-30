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
    
    var disableExportButton: Bool {
        !(exportSavings || exportTransactions || exportRecurringTransactions)
    }
    
    private func getCSVExportString(for list: [any CSVRepresentable], headers: String) -> String {
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
    
    private func writeStringToDisk(content: String, filename: String) -> Bool {
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func handleExportTransactions() -> Bool {
        let transactions = getCSVExportString(for: TransactionFetchController.all.items.value, headers: CSVValidHeaders.transactionCSV.rawValue)
        let transactionsFilename = getFilenameWithPrefix(filename: "transactions")
        return writeStringToDisk(content: transactions, filename: transactionsFilename)
    }
    
    private func handleExportSavings() -> Bool {
        let savings = getCSVExportString(for: SavingStorage.shared.items.value, headers: CSVValidHeaders.savingsCSV.rawValue)
        let savingsFilename = getFilenameWithPrefix(filename: "savings")
        return writeStringToDisk(content: savings, filename: savingsFilename)
    }
    
    private func handleExportRecurringTransactions() -> Bool {
        let recurringTransactions = getCSVExportString(for: RecurringTransactionFetchController.all.items.value, headers: CSVValidHeaders.recurringTransactionCSV.rawValue)
        let recurringTransactionsFilename = getFilenameWithPrefix(filename: "recurring_transactions")
        return writeStringToDisk(content: recurringTransactions, filename: recurringTransactionsFilename)
    }
    
    // MARK: - Intents
    func triggerExport() -> Bool {
        var successful: Bool = false
        if exportSavings {
            successful = handleExportSavings()
        }
        if exportTransactions {
            successful = handleExportTransactions()
        }
        if exportRecurringTransactions {
            successful = handleExportRecurringTransactions()
        }
        return successful
    }
}
