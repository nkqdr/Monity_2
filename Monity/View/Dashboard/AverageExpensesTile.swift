//
//  AverageExpensesTile.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct AverageExpensesTile: View {
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    private var actualTile: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Average Expenses").groupBoxLabelTextStyle(.secondary)
                Spacer()
                Text("Last Year").groupBoxLabelTextStyle(.secondary)
            }
            Spacer()
            Text("Monthly: \(content.averageExpenses.formatted(.currency(code: "EUR")))")
                .font(.headline).bold()
            AverageOneYearBarChart(data: content.monthlyExpenseDataPoints, average: content.averageExpenses, tint: .red)
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

struct AverageExpensesTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
