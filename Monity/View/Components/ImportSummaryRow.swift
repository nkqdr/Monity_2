//
//  ImportSummaryRows.swift
//  Monity
//
//  Created by Niklas Kuder on 15.10.22.
//
import SwiftUI

struct ImportSummaryRow: View {
    var resource: CSVValidHeaders
    var row: String
    var rowContents: [String] {
        Utils.separateCSVRow(row)
    }
    
    var body: some View {
        Group {
            if resource == CSVValidHeaders.transactionCSV {
                transactionRow
            } else if resource == CSVValidHeaders.savingsCSV {
                savingsRow
            } else if resource == CSVValidHeaders.recurringTransactionCSV {
                recurringExpenseRow
            }
        }
        .frame(maxHeight: 100)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    var recurringExpenseRow: some View {
        let obj = RecurringTransaction.decodeFromCSV(csvRow: row)        
        return HStack {
            VStack(alignment: .leading) {
                if !obj.categoryName.isEmpty {
                    Text(obj.categoryName)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                Text(obj.name)
                    .fontWeight(.bold)
                Spacer()
                HStack {
                    Text(obj.startDate, format: .dateTime.year().month().day())
                    Text("-")
                    if let endDate = obj.endDate {
                        Text(endDate, format: .dateTime.year().month().day())
                    } else {
                        Text("Today")
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(obj.cycle.name)
                    .foregroundColor(.secondary)
                Spacer()
                Text(obj.amount, format: .customCurrency())
                    .foregroundColor(obj.amount > 0 ? .green : .red)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }
    
    var savingsRow: some View {
        let csvObj = SavingsEntry.decodeFromCSV(csvRow: row)
        return HStack {
            VStack(alignment: .leading) {
                Text(csvObj.categoryName)
                    .fontWeight(.bold)
                Spacer()
                HStack {
                    Circle()
                        .foregroundColor(csvObj.categoryLabel.color)
                        .frame(width: 15)
                    Text(LocalizedStringKey(csvObj.categoryLabel.rawValue))
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(csvObj.date, format: .dateTime.year().month().day())
                    .foregroundColor(.secondary)
                Spacer()
                Text(csvObj.amount, format: .customCurrency())
                    .foregroundColor(csvObj.amount > 0 ? .green : .red)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }
    
    var transactionRow: some View {
        let csvObj = Transaction.decodeFromCSV(csvRow: row)
        return HStack {
            VStack(alignment: .leading) {
                Text(csvObj.categoryName)
                    .fontWeight(.bold)
                Spacer()
                Text(csvObj.description)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(csvObj.date, format: .dateTime.year().month().day())
                    .foregroundColor(.secondary)
                Spacer()
                Text(csvObj.amount, format: .customCurrency())
                    .foregroundColor(csvObj.isExpense ? .red : .green)
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
            ImportSummaryRow(resource: CSVValidHeaders.transactionCSV, row: transactionRow)
            ImportSummaryRow(resource: CSVValidHeaders.savingsCSV, row: savingRow)
        }
    }
}
