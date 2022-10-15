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
                            .gridCellColumns(2)
                    }
                    GridRow {
                        DashboardBox {
                            Text("Performance")
                                .padding()
                        }
                        .gridCellColumns(2)
                    }
                }
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
