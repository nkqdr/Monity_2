//
//  CurrentMonth.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

fileprivate struct BudgetDisplayString: View {
    @AppStorage(AppStorageKeys.monthlyLimit) private var monthlyLimit: Double = 0
    var remainingAmount: Double
    
    var body: some View {
        if monthlyLimit != 0 {
            Text(remainingAmount, format: .customCurrency())
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(remainingAmount >= 0 ? .green : .red)
        } else {
            Text("-")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.secondary)
        }
    }
}

struct CurrentMonthOverviewTile: View {
    @AppStorage(AppStorageKeys.monthlyLimit) private var monthlyLimit: Double = 0
    @State private var remainingAmount: Double = 0
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
                    BudgetDisplayString(remainingAmount: remainingAmount)
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
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
    }
}



fileprivate struct CurrentMonthDetailView: View {
    @AppStorage(AppStorageKeys.monthlyLimit) private var monthlyLimit: Double = 0
    @State private var remainingAmount: Double = 0
    @State private var showDateSelectorSheet: Bool = false
    @StateObject private var content = CurrentMonthViewModel()
    
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
                        BudgetDisplayString(remainingAmount: remainingAmount)
                    }
                }
                Spacer()
                BudgetBattery()
            }
            HStack(alignment: .top) {
                Text("Predicted total expenses:").groupBoxLabelTextStyle()
                Spacer()
                VStack(alignment: .trailing) {
                    Text(content.predictedTotalSpendings, format: .customCurrency())
                        .fontWeight(.bold)
                        .foregroundColor(content.predictedTotalSpendings > monthlyLimit ? .red : .green)
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
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
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
