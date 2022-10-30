//
//  Settings_OptionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 30.10.22.
//

import SwiftUI

struct Settings_OptionsView: View {
    @AppStorage("user_selected_currency") private var selectedCurrency: String = "EUR"
    let currencyOptions: [String] = [
        "AED", "AUD", "BRL", "CAD", "CHF", "EUR", "GBP", "HKD", "INR", "JPY", "USD",
    ]
    
    private var appearanceSection: some View {
        Section(header: Text("Appearance"), footer: Text("You may need to restart the app for the change to take effect.")) {
            Picker("Currency", selection: $selectedCurrency) {
                ForEach(currencyOptions, id: \.self) {
                    Text($0).tag($0)
                }
            }
        }
    }
    
    var body: some View {
        List {
            appearanceSection
            
            Section("Security") {
                
            }
        }
        .navigationTitle("Options")
    }
}

struct Settings_OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_OptionsView()
    }
}
