//
//  SettingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                generalSection
                configurationSection
                helpSection
            }
            .navigationTitle("Settings")
        }
    }
    
    private var generalSection: some View {
        Section("General") {
            NavigationLink("System") {
                Settings_SystemView()
            }
//            NavigationLink("Options") {
//
//            }
        }
    }
    
    private var configurationSection: some View {
        Section("Configuration") {
            NavigationLink("Transactions") {
                Settings_TransactionsView()
            }
            NavigationLink("Savings") {
                Settings_SavingsView()
            }
        }
    }
    
    private var helpSection: some View {
        Section("About") {
            VStack(alignment: .leading) {
                Group {
                    Text(Bundle.main.displayName)
                    Text("Version \(Bundle.main.appVersion)")
                }
                .foregroundColor(.secondary)
                .font(.caption)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
