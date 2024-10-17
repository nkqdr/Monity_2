//
//  ZipBackup.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.24.
//
import Foundation
import SwiftUI

struct ZipBackup: Transferable {
    var data: [CSVExportedFile]
    
    init(data: [CSVExportedFile] = [
        CSVExportedFile(dataType: .transactions(.all)),
        CSVExportedFile(dataType: .savings(.all)),
        CSVExportedFile(dataType: .recurringTransactions(.all))
    ]) {
        self.data = data
    }
    
    private func writeExportedFile(to url: URL) throws {
        for file in data {
            guard let dataType = file.dataType else {
                throw CSVExportedFile.ExportError.invalidInitError("Cannot retrieve data type")
            }
            let fileName: String = dataType.fileName
            let fileURL: URL = url.appendingPathComponent(fileName)
            let fileData: Data = try Data(file.buildTextContent().utf8)
            FileManager.default.createFile(atPath: fileURL.relativePath, contents: fileData)
        }
    }
    
    private func getTmpDirectory() throws -> URL {
        let fm = FileManager.default
        let tmpDirectoryUrl = fm.temporaryDirectory
        let currentDateString: String = Date().ISO8601Format()
        let directoryUrl: URL = tmpDirectoryUrl.appendingPathComponent("backup-\(currentDateString)", isDirectory: true)
        
        if !fm.fileExists(atPath: directoryUrl.relativePath) {
            try fm.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryUrl
    }

    private func createZip(from baseDirectoryUrl: URL) throws -> URL {
        let fm = FileManager.default
        var archiveUrl: URL?
        var error: NSError?

        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: baseDirectoryUrl, options: [.forUploading], error: &error) { (zipUrl) in
            do {
                let tmpUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("latest-backup.zip")
                if fm.fileExists(atPath: tmpUrl.relativePath) {
                    try fm.removeItem(at: tmpUrl)
                }
                try fm.moveItem(at: zipUrl, to: tmpUrl)
                archiveUrl = tmpUrl
            } catch {
                print("Error moving zip file: \(error)")
            }
        }

        guard let archiveUrl = archiveUrl else {
            throw NSError(domain: "ZipExportError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create zip file"])
        }

        return archiveUrl
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .zip) { exportedFile in
            let tmpDir: URL = try exportedFile.getTmpDirectory()
            try! exportedFile.writeExportedFile(to: tmpDir)
            let zipURL: URL = try exportedFile.createZip(from: tmpDir)
            print(zipURL)
            return SentTransferredFile(zipURL, allowAccessingOriginalFile: true)
        }
    }
}

struct CSVExportedFile: Transferable {
    enum ExportError: Error {
        case invalidInitError(String)
    }
    enum ExportedData {
        case transactions(TransactionFetchController)
        case recurringTransactions(RecurringTransactionFetchController)
        case savings(SavingsFetchController)
        
        var dataRows: [any CSVRepresentable] {
            switch self {
            case let .transactions(fetchController):
                return fetchController.items.value
            case let .recurringTransactions(fetchController):
                return fetchController.items.value
            case let .savings(fetchController):
                return fetchController.items.value
            }
        }
        
        var headers: CSVValidHeaders {
            switch self {
            case .transactions:
                return CSVValidHeaders.transactionCSV
            case .recurringTransactions:
                return CSVValidHeaders.recurringTransactionCSV
            case .savings:
                return CSVValidHeaders.savingsCSV
            }
        }
        
        var fileName: String {
            switch self {
                case .transactions:
                return "Transactions.csv"
            case .recurringTransactions:
                return "RecurringTransactions.csv"
            case .savings:
                return "Savings.csv"
            }
        }
    }
    let dataType: ExportedData?
    private var textContent: String?
    
    init(dataType: ExportedData) {
        self.dataType = dataType
        self.textContent = nil
    }
    
    init(data: Data) throws {
        self.textContent = String(data: data, encoding: .utf8)
        self.dataType = nil
    }
    
    func buildTextContent() throws -> String {
        if let content = self.textContent {
            return content
        }
        guard let dataType = self.dataType else {
            throw ExportError.invalidInitError("Couldn't find textContent or dataType value.")
        }
        let csvRows = dataType.dataRows
        let headers = dataType.headers.rawValue
        var exportString: String = headers + "\n"
        for item in csvRows {
            exportString += item.commaSeparatedString + "\n"
        }
        return exportString
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .commaSeparatedText) { exportedFile in
            let content = try exportedFile.buildTextContent()
            return Data(content.utf8)
        } importing: { received in
            try Self.init(data: received)
        }.suggestedFileName("MonityExport")
    }
}
