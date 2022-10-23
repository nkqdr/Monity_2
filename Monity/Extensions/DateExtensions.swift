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
    
    public var toDate: Date {
        Calendar.current.date(from: self) ?? Date()
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
    
    private func isSameXAs(_ otherDate: Date, comps: Set<Calendar.Component>) -> Bool {
        let myComps: DateComponents = Calendar.current.dateComponents(comps, from: self)
        let otherComps: DateComponents = Calendar.current.dateComponents(comps, from: otherDate)
        return Calendar.current.date(from: myComps) == Calendar.current.date(from: otherComps)
    }
    
    public func isSameMonthAs(_ otherDate: Date) -> Bool {
        return isSameXAs(otherDate, comps: [.year, .month])
    }
    
    public func isSameDayAs(_ otherDate: Date) -> Bool {
        return isSameXAs(otherDate, comps: [.year, .month, .day])
    }
    
    public var isInLastYear: Bool {
        let currentComps: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let oneYearAgoTodayComps: DateComponents = DateComponents(year: (currentComps.year ?? 0) - 1, month: currentComps.month)
        let oneYearAgoToday: Date = Calendar.current.date(from: oneYearAgoTodayComps) ?? Date()
        return self.removeTimeStampAndDay ?? Date() > oneYearAgoToday
    }
    
    public var startOfThisMonth: Date {
        let myComps: DateComponents = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: DateComponents(year: myComps.wrappedYear, month: myComps.wrappedMonth, day: 1)) ?? Date()
    }
}
