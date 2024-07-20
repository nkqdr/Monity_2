//
//  BudgetBattery.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct BudgetBattery: View {
    var monthlyLimit: Double?
    @ObservedObject private var expenseCalculator = MonthExpenseCalculator.current
    
    private var alreadySpent: Double {
        expenseCalculator.totalExpenses
    }
    
    @ViewBuilder
    private func mainBody(limit: Double) -> some View {
        let remainingPercentage: Double = limit > 0 ? (1 - alreadySpent / limit) : 0
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
    
    @ViewBuilder
    private var noBudgetBody: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial, strokeBorder: .secondary.opacity(0.2))
                    .frame(width: 70, height: 120)
            }
            Text("-")
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
    
    var body: some View {
        if let limit = monthlyLimit {
            mainBody(limit: limit)
        } else {
            noBudgetBody
        }
    }
}

struct BudgetBattery_Previews: PreviewProvider {
    static var previews: some View {
        BudgetBattery()
    }
}
