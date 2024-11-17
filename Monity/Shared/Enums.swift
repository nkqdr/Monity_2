//
//  Enums.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation
import SwiftUI

enum CSVValidHeaders: String, CaseIterable {
    case transactionCSV = "description,amount,date,type,category"
    case savingsCSV = "amount,date,category_name,category_label"
    case recurringTransactionCSV = "name,amount,category,cycle,start_date,end_date"
    
    var resourceName: LocalizedStringKey {
        switch self {
        case .transactionCSV:
            return "Transactions"
        case .savingsCSV:
            return "Savings"
        case .recurringTransactionCSV:
            return "Recurring expenses"
        }
    }
    
    var types: String {
        switch self {
        case .transactionCSV:
            return "string,float,ISO-8601-string,expense | income,string"
        case .savingsCSV:
            return "float,ISO-8601-string,string,Invested | Saved | Liquid"
        case .recurringTransactionCSV:
            return "string,float,string,int,ISO-8601-string,ISO-8601-string"
        }
    }
    
    static func fromValue(_ value: String?) -> CSVValidHeaders? {
        guard let givenValue = value else {
            return nil
        }
        for val in self.allCases {
            if val.rawValue == givenValue {
                return val
            }
        }
        return nil
    }
}

enum Timeframe {
    case pastYear
    case pastMonth
    case currentYear
    case currentMonth
    case total
    
    var startDate: Date? {
        let calendar = Calendar.current
        let now = Date().removeTimeStamp!
        switch self {
        case .pastYear:
            return calendar.date(byAdding: .year, value: -1, to: now)
        case .pastMonth:
            return calendar.date(byAdding: .month, value: -1, to: now)
        case .currentYear:
            let currentYear = calendar.component(.year, from: now)
            let startComponents = DateComponents(year: currentYear, month: 1, day: 1)
            return calendar.date(from: startComponents)
        case .currentMonth:
            let currentYear = calendar.component(.year, from: now)
            let currentMonth = calendar.component(.month, from: now)
            let startComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
            return calendar.date(from: startComponents)
        case .total:
            return Date.distantPast
        }
    }
    
    var numMonths: Int? {
        if self == .total {
            // In this case, the numMonths is dependent on the earliest
            // date where data was stored in the DB.
            // This case should be handled by whatever is accessing this property
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        guard let startDate else {
            return nil
        }
        let comps = calendar.dateComponents([.month], from: startDate, to: now)
        return comps.month
    }
}

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
        for val in self.allCases {
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
    static let onboardingDone = "onboarding_done"
    static let ignoreBudgetSuggestionsDate = "ignore_budget_suggestions_date"
}
