//
//  ImportSummaryRows.swift
//  Monity
//
//  Created by Niklas Kuder on 15.10.22.
//
import SwiftUI

struct ImportSummaryRow: View {
    var summary: ImportCSVSummary
    var row: String
    var rowContents: [String] {
        Utils.separateCSVRow(row)
    }
    
    var body: some View {
        Group {
            if summary.resourceName == "Transactions" {
                transactionRow
            } else if summary.resourceName == "Savings" {
                savingsRow
            }
        }
        .frame(maxHeight: 100)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    var savingsRow: some View {
        let amount: Double = Double(rowContents[0]) ?? 0
        let date: Date = Utils.formatFlutterDateStringToDate(rowContents[1])
        let categoryName: String = rowContents[2]
        let categoryLabel: SavingsCategoryLabel = SavingsCategoryLabel.by(rowContents[3])
        
        return HStack {
            VStack(alignment: .leading) {
                Text(categoryName)
                    .fontWeight(.bold)
                Spacer()
                HStack {
                    Circle()
                        .foregroundColor(categoryLabel.color)
                        .frame(width: 15)
                    Text(LocalizedStringKey(categoryLabel.rawValue))
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(date, format: .dateTime.year().month().day())
                    .foregroundColor(.secondary)
                Spacer()
                Text(amount, format: .currency(code: "EUR"))
                    .foregroundColor(amount > 0 ? .green : .red)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }
    
    var transactionRow: some View {
        let description: String = rowContents[0]
        let amount: Double = Double(rowContents[1]) ?? 0
        let date: Date = Utils.formatFlutterDateStringToDate(rowContents[2])
        let isExpense: Bool = rowContents[3] == "0"
        let categoryName: String = rowContents[4]
        
        return HStack {
            VStack(alignment: .leading) {
                Text(categoryName)
                    .fontWeight(.bold)
                Spacer()
                Text(description)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(date, format: .dateTime.year().month().day())
                    .foregroundColor(.secondary)
                Spacer()
                Text(amount, format: .currency(code: "EUR"))
                    .foregroundColor(isExpense ? .red : .green)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }
}

struct ImportSummaryRow_Previews: PreviewProvider {
    static var previews: some View {
        let transactionRow = "\"Seife, Vitamin C und Zahnpasta\",3.26,2022-07-07T20:00:36.411800,0,\"Sonstiges, und Anderes\""
        let savingRow = "5000.0,2022-10-15T11:17:28.381013,Savings,Saved"
        VStack {
            ImportSummaryRow(summary: ImportCSVSummary(resourceName: "Transactions", rowsAmount: 1, rows: [transactionRow]), row: transactionRow)
            ImportSummaryRow(summary: ImportCSVSummary(resourceName: "Savings", rowsAmount: 1, rows: [savingRow]), row: savingRow)
        }
    }
}
