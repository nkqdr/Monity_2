//
//  DateExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation

extension DateComponents {
    public var wrappedMonth: Int {
        get {
            return self.month ?? Calendar.current.component(.month, from: Date())
        }
        set {
            self.month = newValue
        }
    }
    
    public var wrappedYear: Int {
        get {
            return self.year ?? Calendar.current.component(.year, from: Date())
        }
        set {
            self.year = newValue
        }
    }
}

extension Date {
    public var removeTimeStamp : Date? {
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
   }
    
    public var removeTimeStampAndDay: Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) else {
            return nil
        }
        return date
    }
    
    public func isSameMonthAs(_ otherDate: Date) -> Bool {
        let myComps: DateComponents = Calendar.current.dateComponents([.year, .month], from: self)
        let otherComps: DateComponents = Calendar.current.dateComponents([.year, .month], from: otherDate)
        return myComps.month == otherComps.month && myComps.year == otherComps.year
    }
    
    public var isInLastYear: Bool {
        let currentComps: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let oneYearAgoTodayComps: DateComponents = DateComponents(year: (currentComps.year ?? 0) - 1, month: currentComps.month)
        let oneYearAgoToday: Date = Calendar.current.date(from: oneYearAgoTodayComps) ?? Date()
        return self.removeTimeStampAndDay ?? Date() > oneYearAgoToday
    }
}
