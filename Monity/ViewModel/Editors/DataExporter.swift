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
    
    
    // MARK: - Intents
    
    public func getTransactionCSVContent() -> (String, String) {
        let content = getCSVExportString(for: TransactionFetchController.all.items.value, headers: CSVValidHeaders.transactionCSV.rawValue)
        let fileName = getFilenameWithPrefix(filename: "transactions")
        return (content, fileName)
    }
    
    public func getRecurringTransactionsCSVContent() -> (String, String) {
        let content = getCSVExportString(for: RecurringTransactionFetchController.all.items.value, headers: CSVValidHeaders.recurringTransactionCSV.rawValue)
        let fileName = getFilenameWithPrefix(filename: "recurring_transactions")
        return (content, fileName)
    }
    
    public func getSavingsCSVContent() -> (String, String) {
        let content = getCSVExportString(for: SavingsFetchController.all.items.value, headers: CSVValidHeaders.savingsCSV.rawValue)
        let fileName = getFilenameWithPrefix(filename: "savings")
        return (content, fileName)
    }
}
