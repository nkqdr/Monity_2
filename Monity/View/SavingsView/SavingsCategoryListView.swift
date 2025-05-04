//
//  SavingsCategoryListView.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI

fileprivate struct SavingsEntryList: View {
    var category: SavingsCategory
    var content: SavingsViewModel
    
    var body: some View {
        EditableDeletableItemList(
            viewModel: content
        ) { create, edit, delete in
            ForEach(content.groupedItems) { groupedEntry in
                Section {
                    ForEach(groupedEntry.entries) { entry in
                        EditableDeletableItem(
                            item: entry,
                            confirmationTitle: "Are you sure you want to delete this entry?",
                            confirmationMessage: "This cannot be undone!",
                            onEdit: edit,
                            onDelete: delete) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.wrappedDate, format: .dateTime.year().month().day())
                                    Text(item.wrappedDate, format: .dateTime.hour().minute())
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                                Spacer()
                                Text(item.amount, format: .customCurrency())
                                    .foregroundColor(item.amount >= 0 ? .green : .red)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } header: {
                    Text(groupedEntry.date, format: .dateTime.year())
                }
            }
        } sheetContent: { showSheet, currentItem in
            SavingsEntryFormView(
                editor: SavingsEditor(entry: currentItem)
            )
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SavingsCategoryListProxy: View {
    @ObservedObject var category: SavingsCategory
    
    var body: some View {
        Group {
            SavingsCategoryListView(category: category)
        }
    }
}

struct SavingsCategoryListView: View {
    private var category: SavingsCategory
    @StateObject var content: SavingsViewModel
    @State private var showPredictions: Bool = false
    @State private var predictionYearsRange: Double = 1
    @State private var editCategory: SavingsCategory? = nil
    @State private var addWithCategory: SavingsCategory? = nil
    
    init(category: SavingsCategory) {
        self.category = category
        self._content = StateObject(wrappedValue: SavingsViewModel(category: category))
    }
    
    var dataPoints: [ValueTimeDataPoint] {
        category.lineChartDataPoints(after: Date.distantPast)
    }
    
    var performanceLastYear: (Double, Double) {
        if dataPoints.isEmpty {
            return (0, 0)
        }
        let absPerf = dataPoints.last!.value - (content.lastEntryBeforeLastYear?.value ?? 0)
        let relPerf = absPerf / (dataPoints.filter { $0.date.isInLastYear && $0.value != 0}.first?.value ?? 1)
        return (absPerf, relPerf)
    }
    
    var performanceAllTime: (Double, Double) {
        if dataPoints.isEmpty {
            return (0, 0)
        }
        let absPerf = dataPoints.last!.value - dataPoints.first!.value
        let relPerf = absPerf / (dataPoints.first(where: {$0.value != 0})?.value ?? 1)
        return (absPerf, relPerf)
    }
    
    private func getArrowIcon(absChange: Double) -> String {
        absChange >= 0 ? "arrow.up.forward.square.fill" : "arrow.down.forward.square.fill"
    }
    
    private var shareOfTotalWealth: Double {
        if (dataPoints.isEmpty) {
            return 0
        }
        return dataPoints.last!.value / SavingsCategoryViewModel.shared.currentNetWorth
    }
    
    
    var body: some View {
        List {
            SavingsDPLineChart(
                dataPoints: $content.lineChartDataPoints,
                predictionDataPoints: showPredictions ? category.getPredictionData(years: Int(predictionYearsRange)) : []
            )
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            Section {
                Toggle("Show prediction", isOn: $showPredictions.animation())
                if showPredictions {
                    HStack {
                        Text("\(Int(predictionYearsRange)) Years")
                            .frame(minWidth: 100, alignment: .leading)
                        Spacer()
                        Slider(value: $predictionYearsRange, in: 1...50, step: 1)
                            .onChange(of: predictionYearsRange) { _ in
                                Haptics.shared.play(.soft)
                            }
                    }
                }
            } header: {
                Text("Prediction")
            }
            Section {
                HStack {
                    Text("Label")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(LocalizedStringKey(category.wrappedLabel))
                        .tintedBackground(SavingsCategoryLabel.by(category.wrappedLabel).color)
                }
                HStack {
                    Text("Share of total wealth").foregroundStyle(.secondary)
                    Spacer()
                    Text(shareOfTotalWealth.round(to: 4), format: .percent)
                }
                HStack {
                    Text("Interest Rate").foregroundStyle(.secondary)
                    Spacer()
                    Text(category.interestRate / 100, format: .percent) + Text(" p.a.")
                }
            } header: {
                Text("Details")
            }
            Section {
                HStack {
                    Text("All-Time").foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: getArrowIcon(absChange: performanceAllTime.0))
                        .foregroundStyle(performanceAllTime.0 >= 0 ? .green : .red)
                    VStack(alignment: .trailing) {
                        Text(performanceAllTime.1.round(to: 4), format: .percent)
                            .font(.subheadline)
                        Text(performanceAllTime.0, format: .customCurrency())
                            .font(.footnote)
                    }
                    .foregroundStyle(performanceAllTime.0 >= 0 ? .green : .red)
                }
                HStack {
                    Text("Last Year").foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: getArrowIcon(absChange: performanceLastYear.0))
                        .foregroundStyle(performanceLastYear.0 >= 0 ? .green : .red)
                    VStack(alignment: .trailing) {
                        Text(performanceLastYear.1.round(to: 4), format: .percent)
                            .font(.subheadline)
                        Text(performanceLastYear.0, format: .customCurrency())
                            .font(.footnote)
                    }
                    .foregroundStyle(performanceLastYear.0 >= 0 ? .green : .red)
                }
            } header: {
                Text("Performance")
            }
            Section {
                NavigationLink("All entries", destination: SavingsEntryList(category: category, content: content))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        addWithCategory = category
                    } label: {
                        Label("New entry", systemImage: "plus")
                    }
                    Button {
                        editCategory = category
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
        }
        .addSavingsEntrySheet(category: $addWithCategory)
        .editSavingsCategorySheet(category: $editCategory)
        .navigationTitle(category.wrappedName)
    }
}
