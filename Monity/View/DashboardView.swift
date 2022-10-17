//
//  DashboardView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            List {
                Group {
                    CurrentMonthOverviewTile()
                    AverageExpensesTile()
                    AverageIncomeTile()
//                    Section {
//                        VStack(alignment: .leading) {
//                            Text("Savings").groupBoxLabelTextStyle(.secondary)
//                            Text("To-Do")
//                        }
//                    }
                }
                .listRowInsets(EdgeInsets())
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
