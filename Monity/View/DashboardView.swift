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
                LazyVGrid(columns: [GridItem()]) {
                    CurrentMonthOverviewTile()
                    GroupBox(label: Text("Average Expenses").groupBoxLabelTextStyle(.secondary)) {
                        Text("To-Do")
                            .padding()
                    }
                    .gridCellColumns(2)
                    GroupBox(label: Text("Average Income").groupBoxLabelTextStyle(.secondary)) {
                        Text("To-Do")
                            .padding()
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
