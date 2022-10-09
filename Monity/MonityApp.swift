//
//  MonityApp.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

@main
struct MonityApp: App {
    let persistenceController = PersistenceController.shared
        @State private var tabSelection = 1

        var body: some Scene {
            WindowGroup {
                TabView(selection: $tabSelection) {
                    TransactionsView()
                        .tabItem {
                            Label("Transactions", systemImage: "arrow.left.arrow.right")
                        }
                        .tag(0)
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "chart.bar.xaxis")
                        }
                        .tag(1)
                    WealthView()
                        .tabItem {
                            Label("Wealth", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .tag(2)
                }
                
            }
        }
}
