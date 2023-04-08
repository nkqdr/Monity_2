//
//  DashboardView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct DashboardView: View {
    @AppStorage(AppStorageKeys.showSavingsOnDashboard) private var showSavingsOnDashboard: Bool = true
    
    var body: some View {
        NavigationStack {
            ListBase {
                ScrollView {
                    Group {
                        CurrentMonthOverviewTile()
                        AverageExpenseAndIncomeTile()
                        RecurringTransactionsTile()
                        if showSavingsOnDashboard {
                            SavingsTile()
                        }
                    }
                    .padding()
                }
                .onChange(of: showSavingsOnDashboard) { val in
                    print(val)
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
