//
//  Utils.swift
//  Monity
//
//  Created by Niklas Kuder on 15.10.22.
//

import Foundation
import SwiftUI

class Utils {
    static let dateStringRepr: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    
    static func formatDateToISOString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateStringRepr
        return formatter.string(from: date)
    }
    
    static func formatFlutterDateStringToDate(_ str: String) -> Date {
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = dateStringRepr
        let date = newFormatter.date(from: str)
        return date ?? Date()
    }
    
    static func separateCSVRow(_ row: String) -> [String] {
        if !row.contains("\"") {
            return row.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        }
        // Handle quotes in this row
        var comps: [String] = []
        var ignoreComma: Bool = false
        var currentComp: String = ""
        for char in row {
            if char == "\"" {
                ignoreComma.toggle()
                continue
            }
            if char != "," || ignoreComma {
                currentComp.append(char)
            } else {
                comps.append(currentComp)
                currentComp = ""
            }
        }
        comps.append(currentComp)
        return comps
    }
}
