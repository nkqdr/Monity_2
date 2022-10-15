//
//  Utils.swift
//  Monity
//
//  Created by Niklas Kuder on 15.10.22.
//

import Foundation
import SwiftUI

class Utils {
    static func getColorForSavingsLabel(_ label: String) -> Color {
        switch label {
        case "Invested":
            return Color.blue
        case "Saved":
            return Color.yellow
        case "Liquid":
            return Color.purple
        default:
            return Color.red
        }
    }
    
    static func dateRepresentationFor(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    static func formatFlutterDateStringToDate(_ str: String) -> Date {
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
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
