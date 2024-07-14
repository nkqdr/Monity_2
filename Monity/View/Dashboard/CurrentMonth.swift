//
//  CurrentMonth.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

fileprivate struct BudgetDisplayString: View {
    var remainingAmount: Double?
    
    var body: some View {
        if let amount = remainingAmount {
            Text(amount, format: .customCurrency())
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(amount >= 0 ? .green : .red)
        } else {
            Text("-")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.secondary)
        }
    }
}

struct CurrentMonthOverviewTile: View {
    @ObservedObject private var content = CurrentMonthViewModel()
    
    @ViewBuilder
    var actualTile: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Days left:")
                        .font(.system(size: 18, weight: .semibold))
                    Text("\(content.remainingDays)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Budget:")
                        .font(.system(size: 18, weight: .semibold))
                    BudgetDisplayString(remainingAmount: content.remainingAmount)
                }
            }
        }
    }
    
    var body: some View {
        NavigationLink(destination: CurrentMonthDetailView()) {
            GroupBox(label: NavigationGroupBoxLabel(title: "Current Month")) {
                actualTile
            }
            .groupBoxStyle(CustomGroupBox())
            .contextMenu {
                RenderAndShareButton(previewTitle: "Current Month", height: 100) {
                    VStack(alignment: .leading) {
                        Text("Current Month").groupBoxLabelTextStyle(.secondary)
                        Spacer()
                        actualTile
                    }
                    .padding()
                }
            }
        }
        .buttonStyle(.plain)
    }
}



fileprivate struct CurrentMonthDetailView: View {
    @State private var showDateSelectorSheet: Bool = false
    @StateObject private var content = CurrentMonthViewModel()
    
    private var predictedExpensesColor: Color {
        guard let limit = content.currentMonthlyLimit else { return .primary }
        return content.predictedTotalSpendings > limit ? .red : .green
    }
    
    var overviewHeader: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("Days left:")
                            .font(.system(size: 18, weight: .semibold))
                        Text("\(content.remainingDays)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text("Budget:")
                            .font(.system(size: 18, weight: .semibold))
                        BudgetDisplayString(remainingAmount: content.remainingAmount)
                    }
                }
                Spacer()
                BudgetBattery(monthlyLimit: content.currentMonthlyLimit)
            }
            HStack(alignment: .top) {
                Text("Predicted total expenses:").groupBoxLabelTextStyle()
                Spacer()
                VStack(alignment: .trailing) {
                    Text(content.predictedTotalSpendings, format: .customCurrency())
                        .fontWeight(.bold)
                        .foregroundColor(predictedExpensesColor)
                    Group {
                        Text("Ø ") + Text(content.spendingsPerDay, format: .customCurrency()) + Text(" / Day")
                    }
                    .foregroundColor(.secondary)
                    .font(.caption)
                }
            }
            .padding(.vertical, 5)
        }
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
    
    var body: some View {
        ListBase {
            ScrollView {
                if content.selectedDate.toDate.isSameMonthAs(Date()) {
                    overviewHeader
                        .transition(.scale)
                }
                Group {
                    IncomeGroupBox(date: content.selectedDate.toDate)
                    ExpensesGroupBox(date: content.selectedDate.toDate)
                    CashflowChartGroupBox(date: content.selectedDate.toDate)
                }
                .groupBoxStyle(CustomGroupBox())
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        .monthYearSelectorSheet($showDateSelectorSheet, selection: $content.selectedDate)
        .navigationTitle(LocalizedStringKey(content.currentMonthSelected ? "Current Month" : content.selectedDate.toDate.formatted(.dateTime.year().month())))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDateSelectorSheet.toggle()
                } label: {
                    Image(systemName: content.currentMonthSelected ? "tray.full" : "tray.full.fill")
                }
            }
        }
    }
}

struct CurrentMonthDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentMonthDetailView()
    }
}
