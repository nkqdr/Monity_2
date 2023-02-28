//
//  Enums.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation
import SwiftUI

enum TransactionCycle: Int16, CaseIterable {
    
    case monthly = 0
    case yearly = 1
    case weekly = 2
    case biWeekly = 3
    
    var name: LocalizedStringKey {
        switch self {
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        case .weekly:
            return "Weekly"
        case .biWeekly:
            return "Bi-Weekly"
        }
    }
}
