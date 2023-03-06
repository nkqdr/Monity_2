//
//  TypeExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 06.03.23.
//

import Foundation

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

