//
//  SettingsSystemViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import Combine
import Algorithms
import CoreData


class CSVImporter: ObservableObject {
    @Published var importSummary: ImportCSVSummary?
    @Published var importHasError: Bool = false
    @Published var isReading: Bool = false
    @Published var showDocumentPicker: Bool = false
    @Published var importProgress: Double = 0
    @Published var importComplete: Bool = false
    @Published var csvFileContent: String = "" {
        didSet {
            if !csvFileContent.isEmpty {
                handleContentChange()
            }
        }
    }
    @Published var showInvalidFileAlert: Bool = false
    
    
    // MARK: - Helper functions
    
    private func handleContentChange() {
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
        self.importComplete = false
        guard let summary = importSummary else {
            return
        }
        let moc: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = PersistenceController.shared.container.persistentStoreCoordinator
        
        var storage: CoreDataStorage
        if summary.resourceName == "Transactions" {
            storage = TransactionStorage(managedObjectContext: moc)
        } else if summary.resourceName == "Savings" {
            storage = SavingStorage(managedObjectContext: moc)
        } else if summary.resourceName == "Recurring expenses" {
            storage = RecurringTransactionStorage(managedObjectContext: moc)
        } else {
            return
        }
        self.importProgress = 0.0001
        DispatchQueue.global(qos: .background).async {
            let chunks = summary.rows.chunks(ofCount: 10_000)
            for (index, chunk) in chunks.enumerated() {
                let result = storage.add(set: chunk)
                DispatchQueue.main.async {
                    if !result {
                        self.showInvalidFileAlert.toggle()
                    } else {
                        self.importProgress = ((Double(index) + 1) / Double(chunks.count))
                        print(self.importProgress)
                        if self.importProgress == 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.importComplete = true
                                Haptics.shared.notify(.success)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                dismissFunc()
                            }
                        }
                    }
                }
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
