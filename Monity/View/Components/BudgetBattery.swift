//
//  BudgetBattery.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct BudgetBattery: View {
    var monthlyLimit: Double
    var alreadySpent: Double
    
    var body: some View {
        let remainingPercentage: Double = monthlyLimit > 0 ? (1 - alreadySpent / monthlyLimit) : 0
        let batteryColor: Color = remainingPercentage > 0.1 ? .green : .red
        let remainingBatteryHeight: Double = remainingPercentage > 0 ? 120 * remainingPercentage : 0
        let textColor: Color? = remainingPercentage > 0 ? nil : .red
        ZStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial, strokeBorder: batteryColor.opacity(0.2))
                    .frame(width: 70, height: 120)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 70, height: remainingBatteryHeight)
                    .foregroundStyle(batteryColor.gradient)
            }
            Text(String(format: "%.1f", 100 * remainingPercentage) + "%")
                .fontWeight(.bold)
                .foregroundColor(textColor)
        }
    }
}

struct BudgetBattery_Previews: PreviewProvider {
    static var previews: some View {
        BudgetBattery(monthlyLimit: 1000, alreadySpent: 342.1)
    }
}
