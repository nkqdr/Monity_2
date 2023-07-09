//
//  DashboardView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ListBase {
                ScrollView {
                    Group {
                        CurrentMonthOverviewTile()
                        TransactionSummaryTile()
                        RecurringTransactionsTile()
                        SavingsTile()
                    }
                    .padding()
                }
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
