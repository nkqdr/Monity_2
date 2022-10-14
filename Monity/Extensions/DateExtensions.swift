//
//  DateExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation

extension DateComponents {
    var wrappedMonth: Int {
        get {
            return self.month ?? Calendar.current.component(.month, from: Date())
        }
        set {
            self.month = newValue
        }
    }
    
    var wrappedYear: Int {
        get {
            return self.year ?? Calendar.current.component(.year, from: Date())
        }
        set {
            self.year = newValue
        }
    }
}
