//
//  CategorySummaryTile.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import SwiftUI

struct CategorySummaryTile: View {
    var dataPoint: CategoryRetroDataPoint
    
    var body: some View {
        NavigationLink(destination: TransactionCategorySummaryView(category: dataPoint.category)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(dataPoint.category.wrappedName)
                        .fontWeight(.bold)
                    Text("\(dataPoint.numTransactions) transactions")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(dataPoint.total, format: .currency(code: "EUR"))
                        .fontWeight(.semibold)
                    Text("Ø\(dataPoint.average.formatted(.currency(code: "EUR"))) p.m.")
                        .font(.caption2)
                }
                .foregroundColor(Color.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

struct TransactionSummaryTile_Previews: PreviewProvider {
    static func getTestCategory() -> TransactionCategory {
        let category = TransactionCategory(context: PersistenceController.preview.container.viewContext)
        category.id = UUID()
        category.name = "Test Category"
        return category
    }
    
    static var previews: some View {
        let category = getTestCategory()
        CategorySummaryTile(dataPoint: CategoryRetroDataPoint(category: category, total: 121.6, average: 10.5, numTransactions: 21))
    }
}
