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
                
            }
            NavigationLink("Options") {
                
            }
            NavigationLink("Appearance") {
                
            }
        }
    }
    
    private var configurationSection: some View {
        Section("Configuration") {
            NavigationLink("Transactions") {
                Settings_TransactionsView()
            }
            NavigationLink("Investments") {
                
            }
        }
    }
    
    private var helpSection: some View {
        Section("Help") {
            NavigationLink("About") {
                
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
