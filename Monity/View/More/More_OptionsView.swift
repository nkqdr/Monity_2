//
//  More_OptionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 30.10.22.
//

import SwiftUI

struct More_OptionsView: View {
    @AppStorage(AppStorageKeys.selectedCurrency) private var selectedCurrency: String = "EUR"
    @AppStorage(AppStorageKeys.appIcon) private var activeAppIconStored: String = "None"
    @AppStorage(AppStorageKeys.integrateRecurringExpensesInCalculations) private var integrateRecurringExpensesInOverview: Bool = true
    @AppStorage(AppStorageKeys.showSavingsProjections) private var showProjections: Bool = true
    
    @State private var activeAppIcon: String? = nil {
        didSet {
            activeAppIconStored = activeAppIcon ?? "None"
            UIApplication.shared.setAlternateIconName(activeAppIcon)
        }
    }
    
    private var gridItems: [GridItem] {
        if iconOptions.count > 2 {
            return [GridItem(), GridItem(), GridItem()]
        }
        return [GridItem(), GridItem()]
    }
    
    init() {
        if activeAppIconStored != "None" {
            self._activeAppIcon = State(initialValue: activeAppIconStored)
        }
    }
    
    let currencyOptions: [String] = [
        "AED", "AUD", "BRL", "CAD", "CHF", "EUR", "GBP", "HKD", "INR", "JPY", "USD",
    ]
    
    private let iconOptions: [IconSetup] = [
        IconSetup(iconName: "IconImageLight", tag: nil),
        IconSetup(iconName: "IconImageDark", tag: "AppIcon 1")
    ]
    
    private var appearanceSection: some View {
        Section(header: Text("Appearance"), footer: Text("You may need to restart the app for the changes to take effect.")) {
            Picker("Currency", selection: $selectedCurrency) {
                ForEach(currencyOptions, id: \.self) {
                    Text($0).tag($0)
                }
            }
            VStack(alignment: .leading) {
                Text("App Icon")
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(iconOptions) { icon in
                        Image(icon.iconName)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .background {
                                if activeAppIcon == icon.tag {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 5)
                                        .foregroundColor(.blue)
                                }
                            }
                            .onTapGesture {
                                activeAppIcon = icon.tag
                            }
                    }
                }
            }
            NavigationLink("Dashboard") {
                DashboardSettingsView()
            }
        }
    }
    
    private var recurringExpensesSection: some View {
        Section(header: Text("Recurring expenses"), footer: Text("recurring_expenses.settings_description")) {
            Toggle("Show in month overview", isOn: $integrateRecurringExpensesInOverview)
        }
    }
    
    private var wealthSection: some View {
        Section(header: Text("Savings")) {
            Toggle("Show projections", isOn: $showProjections)
        }
    }
    
    var body: some View {
        List {
            appearanceSection
            recurringExpensesSection
            wealthSection
        }
        .navigationTitle("Settings")
    }
    
    private struct IconSetup: Identifiable {
        var id = UUID()
        var iconName: String
        var tag: String?
    }
}

struct Settings_OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        More_OptionsView()
    }
}
