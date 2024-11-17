//
//  DashboardView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var currentDate: Date = Date()
    
    var showEOYreview: Bool {
        let currentComps = Calendar.current.dateComponents([.month, .day], from: currentDate)
        if currentComps.month != 12 || currentComps.day! < 11 {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            ListBase {
                ScrollView {
                    Group {
                        Suggestions()
                        if showEOYreview {
                            EOY_ReviewTile()
                        }
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
        .onChange(of: scenePhase) { newValue in
            if (scenePhase == .active) {
                currentDate = Date()
            }
        }
    }
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
