//
//  ModelExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation

extension TransactionCategory {
    var wrappedName: String {
        self.name ?? ""
    }
    
    var wrappedTransactionsCount: Int {
        self.transactions?.count ?? 0
    }
}

extension Transaction {
    var wrappedText: String {
        self.text ?? ""
    }
}
