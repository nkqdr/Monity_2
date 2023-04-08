//
//  SavingsCategoryList.swift
//  Monity
//
//  Created by Niklas Kuder on 08.04.23.
//

import SwiftUI

struct SavingsCategoryList: View {
    var categories: [SavingsCategory]
    
    private var sortedCategories: [SavingsCategory] {
        categories.sorted { c1, c2 in
            c1.lastEntry?.amount ?? 0 > c2.lastEntry?.amount ?? 0
        }
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(sortedCategories, id: \.self) { category in
                SavingsCategoryTile(category: category)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
