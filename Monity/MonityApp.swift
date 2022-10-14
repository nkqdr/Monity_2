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
                    SavingsView()
                        .tabItem {
                            Label("Savings", systemImage: "dollarsign")
                        }
                        .tag(2)
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(3)
                }
                
            }
        }
}
