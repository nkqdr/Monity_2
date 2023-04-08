//
//  SavingsTile.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI
import Charts

struct SavingsTile: View {
    @ObservedObject private var content = SavingsCategoryViewModel()
    @AppStorage(AppStorageKeys.showSavingsOnDashboard) private var showSavingsOnDashboard: Bool = true
    
    @ViewBuilder
    var actualTile: some View {
        let displayedPercentage = Int((content.percentChangeInLastYear * 100).rounded())
        
        VStack(alignment: .leading) {
            Group {
                if displayedPercentage >= 0 {
                    Text("Your wealth increased by \(displayedPercentage)%")
                } else {
                    Text("Your wealth decreased by \(-displayedPercentage)%")
                }
            }
            .groupBoxLabelTextStyle()
            StaticSavingsLineChart()
        }
    }
    
    var body: some View {
        if showSavingsOnDashboard {
            NavigationLink(destination: SavingsDetailView()) {
                GroupBox(label: NavigationGroupBoxLabel(title: "Last Year")) {
                    actualTile
                }
                .groupBoxStyle(CustomGroupBox())
            }
            .buttonStyle(.plain)
        }
    }
}

struct SavingsTile_Previews: PreviewProvider {
    static var previews: some View {
        SavingsTile()
    }
}
