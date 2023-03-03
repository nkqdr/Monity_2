//
//  MoreView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                generalSection
                configurationSection
                helpSection
            }
            .navigationTitle("More")
        }
    }
    
    private var generalSection: some View {
        Section("General") {
            NavigationLink("System") {
                More_SystemView()
            }
            NavigationLink("Settings") {
                More_OptionsView()
            }
        }
    }
    
    private var configurationSection: some View {
        Section("Configuration") {
            NavigationLink("Transactions") {
                More_TransactionsView()
            }
            NavigationLink("Savings") {
                More_SavingsView()
            }
        }
    }
    
    private var helpSection: some View {
        Section("About") {
            HStack {
                Image(systemName: "info.circle")
                VStack(alignment: .leading) {
                    Group {
                        Text(Bundle.main.displayName)
                        Text("Version \(Bundle.main.appVersion)")
                    }
                    .font(.caption)
                }
            }
            .foregroundColor(.secondary)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
