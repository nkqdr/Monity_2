//
//  Structures.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import SwiftUI

struct PieChartDataPoint: Identifiable {
    var id: UUID = UUID()
    var title: String
    var value: Double
    var color: Color
}
