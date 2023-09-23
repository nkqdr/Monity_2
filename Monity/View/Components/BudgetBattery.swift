//
//  BudgetBattery.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct BudgetBattery: View {
    @AppStorage(AppStorageKeys.monthlyLimit) private var monthlyLimit: Double = 0
    @ObservedObject private var expenseCalculator = MonthExpenseCalculator.current
    
    private var alreadySpent: Double {
        expenseCalculator.totalExpenses
    }
    
    @ViewBuilder
    private var mainBody: some View {
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
        if monthlyLimit != 0 {
            mainBody
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
