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
            ListBase {
                ScrollView {
                    Group {
                        CurrentMonthOverviewTile()
                        AverageExpenseAndIncomeTile()
                        SavingsTile()
                    }
                    .padding()
                }
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
