//
//  SettingsSystemView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct Settings_SystemView: View {
    @StateObject private var content = SettingsSystemViewModel()
    
    var body: some View {
        List {
            dataSection
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var dataSection: some View {
        Section(header: Text("Data"), footer: Text("Manage all data you have ever saved in this app.")) {
            HStack {
                Text("Registered transactions")
                Spacer()
                Text(content.registeredTransactions, format: .number)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Registered savings entries")
                Spacer()
                Text(content.registeredSavingsEntries, format: .number)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Used storage")
                Spacer()
                Text(content.storageUsedString)
                    .foregroundColor(.secondary)
            }
            HStack {
                Spacer()
                Button("Delete all data", role: .destructive) {
                    print("Delete...")
                }
                .buttonStyle(.borderless)
                Spacer()
            }
        }
    }
}

struct Settings_SystemView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_SystemView()
    }
}
