//
//  RecurringTransactionEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation
import SwiftUI
import Combine

class RecurringTransactionEditor: ObservableObject {
    @Published var isDeducted: Bool = true
    @Published var amount: Double = 0
    @Published var name: String = ""
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var cycle: TransactionCycle = .monthly
    @Published var navigationFormTitle: LocalizedStringKey
    @Published var isStillActive: Bool
    var transaction: RecurringTransaction?
    
    init(transaction: RecurringTransaction? = nil) {
        self.isDeducted = transaction?.isDeducted ?? true
        self.amount = transaction?.amount ?? 0
        self.name = transaction?.name ?? ""
        self.transaction = transaction
        self.startDate = transaction?.startDate ?? Date.now
        self.cycle = TransactionCycle.fromValue(transaction?.cycle) ?? .monthly
        self.navigationFormTitle = (transaction != nil) ? "Edit transaction" : "New transaction"
        self.isStillActive = transaction?.endDate == nil
        self.endDate = transaction?.endDate ?? Date.now
    }
    
    // MARK: - Intents
    
    public func save() {
        if let t = transaction {
            let _ = RecurringTransactionStorage.shared.update(t, editor: self)
        } else {
            let _ = RecurringTransactionStorage.shared.add(name: name, amount: amount, startDate: startDate, endDate: isStillActive ? nil : endDate, cycle: cycle, isDeducted: isDeducted)
        }
    }
}
