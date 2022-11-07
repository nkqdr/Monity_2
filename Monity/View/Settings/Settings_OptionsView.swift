//
//  Settings_OptionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 30.10.22.
//

import SwiftUI

struct Settings_OptionsView: View {
    @AppStorage("user_selected_currency") private var selectedCurrency: String = "EUR"
    @AppStorage("active_app_icon") private var activeAppIconStored: String = "None"
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
        Section(header: Text("Appearance"), footer: Text("You may need to restart the app for the change to take effect.")) {
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
        }
    }
    
    var body: some View {
        List {
            appearanceSection
//            Section("Security") {
//
//            }
        }
        .navigationTitle("Options")
    }
    
    private struct IconSetup: Identifiable {
        var id = UUID()
        var iconName: String
        var tag: String?
    }
}

struct Settings_OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_OptionsView()
    }
}
