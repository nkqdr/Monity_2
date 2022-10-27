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
                    AverageExpenseAndIncomeTile()
                    SavingsTile()
                }
                .listRowInsets(EdgeInsets())
                .padding()
            }
            .navigationTitle("Dashboard")
        }
        .navigationViewStyle(.stack) 
    }
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
