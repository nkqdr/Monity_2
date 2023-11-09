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
                isPresented: showSheet,
                editor: SavingsEditor(entry: currentItem)
            )
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SavingsCategoryListView: View {
    var category: SavingsCategory
    var entryManager: SavingsEntryManager
    @StateObject var content: SavingsViewModel
    
    init(category: SavingsCategory, entryManager: SavingsEntryManager) {
        self.category = category
        self.entryManager = entryManager
        self._content = StateObject(wrappedValue: SavingsViewModel.forCategory(category))
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
            SavingsDPLineChart(dataPoints: $content.lineChartDataPoints)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
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
                Button {
                    entryManager.editor = SavingsEditor(entry: nil)
                    entryManager.editor.category = category
                    entryManager.showSheet.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .navigationTitle(category.wrappedName)
    }
}
