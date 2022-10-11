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
                        CurrentMonthOverviewTile()
                        DashboardBox {
                            Text("Performance")
                        }
                    }
                    GridRow {
                        DashboardBox {
                            Text("Income")
                        }
                        .gridCellColumns(2)
                    }
                    GridRow {
                        DashboardBox {
                            Text("Expenses")
                        }
                        .gridCellColumns(2)
                    }
                    GridRow {
                        DashboardBox {
                            Text("Cashflow")
                        }
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
