//
//  AverageIncomeTile.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct AverageIncomeTile: View {
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    private var actualTile: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Average Income").groupBoxLabelTextStyle(.secondary)
                Spacer()
                Text("Last Year").groupBoxLabelTextStyle(.secondary)
            }
            Spacer()
            Text("Monthly: \(content.averageIncome.formatted(.currency(code: "EUR")))")
                .font(.headline).bold()
            AverageOneYearBarChart(data: content.monthlyIncomeDataPoints, average: content.averageIncome, tint: .green)
                .padding(.horizontal, 4)
        }
    }
    var body: some View {
        Section {
            NavigationLink(destination: EmptyView()) {
                actualTile
            }
        }
    }
}
