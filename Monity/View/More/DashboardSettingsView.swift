//
//  DashboardSettingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 08.04.23.
//

import SwiftUI

struct DashboardSettingsView: View {
    @AppStorage(AppStorageKeys.showSavingsOnDashboard) private var showSavingsOnDashboard: Bool = true
    
    var body: some View {
        Form {
            Section(footer: Text("This setting only implies visual changes. Your data will not be deleted")) {
                Toggle("Show Savings", isOn: $showSavingsOnDashboard)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DashboardSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardSettingsView()
    }
}
