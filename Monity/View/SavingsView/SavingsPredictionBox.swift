//
//  SavingsPredictionBox.swift
//  Monity
//
//  Created by Niklas Kuder on 06.03.23.
//

import SwiftUI
import Charts

struct SavingsPredictionBox: View {
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    var yearAmount: Int
    
    private var projection: Double {
        content.getXYearProjection(yearAmount)
    }
    
    private var accentColor: Color {
        projection >= 0 ? .green : .red
    }
    
    private var percentageChange: Double {
        (projection / content.currentNetWorth - 1).round(to: 3)
    }
    
    private var predictionDate: Date {
        Calendar.current.date(byAdding: DateComponents(year: yearAmount), to: Date()) ?? Date()
    }
    
    private var arrowIcon: String {
        projection >= 0 ? "arrow.up.forward.square.fill" : "arrow.down.forward.square.fill"
    }
    
    private var label: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("\(yearAmount) Years").groupBoxLabelTextStyle()
                Text(predictionDate, format: .dateTime.year().month())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Label(percentageChange.formatted(.percent), systemImage: arrowIcon)
                .foregroundColor(accentColor)
                .font(.subheadline)
        }
    }
    
    var body: some View {
        GroupBox(label: label) {
            HStack {
                Spacer()
                Text(projection, format: .customCurrency())
                    .fontWeight(.bold)
                    .tintedBackground(accentColor)
            }
        }
        .groupBoxStyle(CustomGroupBox())
        .frame(maxHeight: 100)
    }
}

struct SavingsPredictionBox_Previews: PreviewProvider {
    static var previews: some View {
        SavingsPredictionBox(yearAmount: 5)
    }
}
