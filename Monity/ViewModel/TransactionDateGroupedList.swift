//
//  TransactionDateGroupedList.swift
//  Monity
//
//  Created by Niklas Kuder on 06.07.24.
//

import Foundation
import Algorithms
import Combine

class TransactionDateGroupedList: ObservableObject {
    @Published var searchText: String = "" {
        didSet {
            if oldValue != searchText {
                self.performSearch(for: searchText)
            }
        }
    }
    @Published var selectedDateComps: DateComponents = DateComponents() {
        didSet {
            self.performDateRangeChange(for: selectedDateComps)
        }
    }
    @Published var groupedTransactions: [TransactionsByDate] = []
    
    private var category: TransactionCategory?
    private var isExpense: Bool?
    private var groupingGranularity: Calendar.Component
    private var persistenceController: PersistenceController
    
    private var fetchController: TransactionFetchController
    private var transactionCancellable: AnyCancellable?
    private var basePredicate: NSPredicate? = nil
    
    init(
        category: TransactionCategory? = nil,
        isExpense: Bool? = nil,
        monthComponents: DateComponents? = nil,
        groupingGranularity: Calendar.Component,
        controller: PersistenceController = PersistenceController.shared
    ) {
        var startDate: Date? = nil
        var endDate: Date? = nil
        if let monthComponents {
            let date: Date = Calendar.current.date(from: monthComponents) ?? Date()
            startDate = date.startOfThisMonth.removeTimeStamp!
            endDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: startDate!)
            self.selectedDateComps = monthComponents
        }
        self.category = category
        self.isExpense = isExpense
        self.groupingGranularity = groupingGranularity
        self.persistenceController = controller
        self.fetchController = TransactionFetchController(
            category: category, 
            isExpense: isExpense,
            startDate: startDate,
            endDate: endDate,
            controller: controller
        )
        
        let publisher = self.fetchController.items.eraseToAnyPublisher()
        
        self.transactionCancellable = publisher.sink { transactions in
            self.setGroupedTransactions(for: transactions)
        }
    }
    
    private func getStartAndEndDate(for comps: DateComponents?) -> (Date?, Date?) {
        guard let comps else {
            return (nil, nil)
        }
        let date: Date = Calendar.current.date(from: comps) ?? Date()
        let startDate = date.startOfThisMonth.removeTimeStamp!
        let endDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: startDate)
        return (startDate, endDate)
    }
    
    private func performDateRangeChange(for comps: DateComponents) {
        self.transactionCancellable?.cancel()
        self.basePredicate = nil
        
        let dates = self.getStartAndEndDate(for: comps)
        self.fetchController = TransactionFetchController(
            category: self.category,
            isExpense: self.isExpense,
            startDate: dates.0,
            endDate: dates.1,
            controller: self.persistenceController
        )
        let publisher = self.fetchController.items.eraseToAnyPublisher()
        self.transactionCancellable = publisher.sink { transactions in
            self.setGroupedTransactions(for: transactions)
        }
    }
    
    private func performSearch(for search: String) {
        let controller = self.fetchController.itemFetchController
        let predicate = controller.fetchRequest.predicate
        
        if self.basePredicate == nil {
            self.basePredicate = predicate
        }
        
        if search.isEmpty {
            controller.fetchRequest.predicate = self.basePredicate
        } else {
            controller.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                self.basePredicate ?? NSPredicate(value: true),
                NSPredicate(format: "text CONTAINS[cd] %@ OR category.name CONTAINS[cd] %@", search, search)
            ])
        }
        
        do {
            try controller.performFetch()
            self.fetchController.controllerDidChangeContent(controller)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setGroupedTransactions(for transactions: [Transaction]) {
        self.groupedTransactions = []
        DispatchQueue.main.async {
            let chunkedTransactions = transactions.chunked(by: {
                Calendar.current.isDate($0.wrappedDate, equalTo: $1.wrappedDate, toGranularity: self.groupingGranularity)
            }).filter { !$0.isEmpty }
            
            var byDate: [TransactionsByDate] = []
            
            for chunk in chunkedTransactions {
                guard let chunkDate = chunk.first?.wrappedDate else {
                    continue
                }
                let transactionBlock = self.groupedTransactions.first(where: { Calendar.current.isDate(chunkDate, inSameDayAs: $0.date)})
                
                guard let transactionBlock else {
                    byDate.append(TransactionsByDate(date: chunkDate, transactions: Array(chunk)))
                    continue
                }
                var newBlock = transactionBlock
                newBlock.setTransactions(Array(chunk))
                byDate.append(newBlock)
            }
            
            let sortedGroupedTransactions = byDate.sorted {
                $0.date > $1.date
            }
            
            self.groupedTransactions = sortedGroupedTransactions
        }
    }
}

