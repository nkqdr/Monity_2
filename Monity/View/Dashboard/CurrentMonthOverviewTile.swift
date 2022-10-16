//
//  CurrentMonthOverviewTile.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import SwiftUI

struct CurrentMonthOverviewTile: View {
    @AppStorage("monthly_limit") private var monthlyLimit: Double = 0
    @State private var remainingAmount: Double = 0
    @StateObject private var content = MonthlyOverviewViewModel()
    
    @ViewBuilder
    var actualTile: some View {
        let label = Text("Current Month").font(.subheadline).foregroundColor(.secondary)
        GroupBox(label: label) {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text("Days left:")
                        .font(.system(size: 18, weight: .semibold))
                    Text("\(content.remainingDays)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text("Budget:")
                        .font(.system(size: 18, weight: .semibold))
                    Text(remainingAmount, format: .currency(code: "EUR"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(remainingAmount >= 0 ? .green : .red)
                }
            }
        }
        .onlyHideContextMenu {
            if monthlyLimit > 0 {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Predicted total expenses:")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                        Text(content.predictedTotalSpendings, format: .currency(code: "EUR"))
                            .foregroundColor(content.predictedTotalSpendings > monthlyLimit ? .red : .green)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer(minLength: 60)
                    budgetBattery
                }
                .frame(maxWidth: .infinity, maxHeight: 350)
                .padding()
            } else {
                VStack {
                    Text("Please set a monthly limit in the settings in order to use this.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(height: 350)
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
    }
    
//    var actualTile: some View {
//        PreviewDashboardBox {
//            VStack(alignment: .leading) {
//                HStack {
//                    Text("Month Overview")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Spacer()
//                }
//                Spacer()
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text("Days left:")
//                            .font(.system(size: 18, weight: .semibold))
//                        Text("\(content.remainingDays)")
//                            .font(.system(size: 22, weight: .bold))
//                            .foregroundColor(.secondary)
//                    }
//                    Spacer()
//                    VStack {
//                        Text("Budget:")
//                            .font(.system(size: 18, weight: .semibold))
//                        Text(remainingAmount, format: .currency(code: "EUR"))
//                            .font(.system(size: 22, weight: .bold))
//                            .foregroundColor(remainingAmount >= 0 ? .green : .red)
//                    }
//                }
//            }
//            .padding()
//        } previewContent: {
//            if monthlyLimit > 0 {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text("Predicted total expenses:")
//                            .font(.system(size: 18, weight: .semibold))
//                            .frame(maxWidth: .infinity)
//                        Text(content.predictedTotalSpendings, format: .currency(code: "EUR"))
//                    }
//                    .frame(maxWidth: .infinity)
//                    Spacer(minLength: 60)
//                    budgetBattery
//                }
//                .frame(maxWidth: .infinity, maxHeight: 350)
//                .padding()
//            } else {
//                VStack {
//                    Text("Please set a monthly limit in the settings in order to use this.")
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.secondary)
//                }
//                .frame(height: 350)
//                .frame(maxWidth: .infinity)
//                .padding()
//            }
//        }
//
//    }
    
    var body: some View {
        NavigationLink(destination: CurrentMonthDetailView()) {
            actualTile
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var budgetBattery: some View {
        let remainingPercentage: Double = (1 - content.spentThisMonth / monthlyLimit)
        let batteryColor: Color = remainingPercentage > 0.1 ? .green : .red
        let remainingBatteryHeight: Double = remainingPercentage > 0 ? 120 * remainingPercentage : 0
        let textColor: Color? = remainingPercentage > 0 ? nil : .red
        ZStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 70, height: 120)
                    .foregroundColor(.clear)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
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

struct CurrentMonthOverviewTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
