//
//  CurrencyPieChart.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct CurrencyPieChart: View {
    let values: [Double]
    var colors: [Color]
    var backgroundColor: Color = .clear
    var showSliceLabels: Bool = false
    var centerLabel: Double
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                PieChart(values: values, colors: colors, backgroundColor: backgroundColor, showSliceLabels: showSliceLabels)
                let size = min(proxy.size.width, proxy.size.height) * 0.6
                ZStack {
                    Circle()
                        .foregroundStyle(.thinMaterial)
                    Text(centerLabel, format: .currency(code: "EUR"))
                        .font(.subheadline)
                        .padding(5)
                }
                .frame(width: size, height: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
