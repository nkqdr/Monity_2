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
            ScrollView(showsIndicators: false) {
                Grid {
                    GridRow {
                        DashboardBox(title: "Monthly overview")
                        DashboardBox(title: "Performance")
                    }
                    GridRow {
                        DashboardBox(title: "Income")
                            .gridCellColumns(2)
                    }
                    GridRow {
                        DashboardBox(title: "Expenses")
                            .gridCellColumns(2)
                    }
                    GridRow {
                        DashboardBox(title: "Cashflow")
                            .gridCellColumns(2)
                    }
                }
                .padding()
            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: {
//                        SettingsView()
//                    }, label: {
//                        Image(systemName: "gearshape.fill")
//                    })
//                }
//            }
            .navigationTitle("Dashboard")
        }
    }
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
