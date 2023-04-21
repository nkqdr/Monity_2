//
//  SavingsProjections.swift
//  Monity
//
//  Created by Niklas Kuder on 08.04.23.
//

import SwiftUI

struct SavingsProjections: View {
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    @AppStorage(AppStorageKeys.showSavingsProjections) private var showProjections: Bool = true
    private let savingsProjectionYears: [Int] = [1, 5, 10, 25, 50]
    
    var horizontalScrollView: some View {
        VStack(alignment: .leading) {
            Text("Future Projections").textCase(.uppercase).font(.footnote).foregroundColor(.secondary).padding(.bottom, 1)
                .padding(.horizontal, 30)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(savingsProjectionYears, id: \.self) { yearAmount in
                        SavingsPredictionBox(yearAmount: yearAmount)
                            .frame(minWidth: 300, minHeight: 50)
                    }
                }
                .padding(.horizontal)
            }
            HStack(alignment: .bottom) {
                Text("Average change per year:")
                    .font(.footnote).foregroundColor(.secondary).padding(.top, 5)
                Spacer()
                Text(content.yearlySavingsRate, format: .customCurrency())
                    .font(.footnote).foregroundColor(content.yearlySavingsRate >= 0 ? .green : .red).padding(.top, 1)
            }
            .padding(.horizontal, 30)
        }
    }
    
    var body: some View {
        if (showProjections) {
            horizontalScrollView
                .padding(.vertical)
        }
    }
}

struct SavingsProjections_Previews: PreviewProvider {
    static var previews: some View {
        SavingsProjections()
    }
}
