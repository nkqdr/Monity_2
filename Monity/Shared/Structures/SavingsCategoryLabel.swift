//
//  SavingsCategoryLabel.swift
//  Monity
//
//  Created by Niklas Kuder on 30.06.24.
//

import Foundation
import SwiftUI

enum SavingsCategoryLabel: String, CaseIterable {
    case liquid = "Liquid"
    case saved = "Saved"
    case invested = "Invested"
    case none = ""
    
    var color: Color {
        switch self {
        case .none: return Color.clear
        case .saved: return Color.yellow
        case .invested: return Color.green
        case .liquid: return Color.blue
        }
    }
    
    static var allCasesWithoutNone: [SavingsCategoryLabel] {
        var cases = self.allCases
        let removed = cases.removeLast()
        if removed != .none {
            fatalError("The wrong label got removed.")
        }
        return cases
    }
    
    static func by(_ repr: String?) -> SavingsCategoryLabel {
        for label in SavingsCategoryLabel.allCases {
            if label.rawValue == repr {
                return label
            }
        }
        return SavingsCategoryLabel.none
    }
}
