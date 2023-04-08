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
    
    var dividerForMonthlyValue: Double {
        switch self {
        case .monthly:
            return 1
        case .yearly:
            return 12
        case .weekly:
            return 0.25
        case .biWeekly:
            return 0.5
        }
    }
    
    static func fromValue(_ value: Int16?) -> TransactionCycle? {
        guard let givenValue = value else {
            return nil
        }
        for val in TransactionCycle.allCases {
            if val.rawValue == givenValue {
                return val
            }
        }
        return nil
    }
}

struct AppStorageKeys {
    static let monthlyLimit = "monthly_limit"
    static let selectedCurrency = "user_selected_currency"
    static let appIcon = "active_app_icon"
    static let showSavingsOnDashboard = "show_savings_on_dashboard"
    static let integrateRecurringExpensesInCalculations = "integrate_recurring_expenses_in_month_overview"
    static let showSavingsProjections = "show_projections_in_savings_overview"
}
