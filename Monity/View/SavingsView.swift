//
//  SavingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI

struct SavingsView: View {
    @State var showAddEntryView = false
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    @ObservedObject private var entryContent = SavingsViewModel.shared
    
    @ViewBuilder
    func categoryTile(_ category: SavingsCategory) -> some View {
        let currentAmount: Double? = category.lastEntry?.amount
        HStack {
            VStack(alignment: .leading) {
                Text(category.wrappedName)
                Text("Associated entries: \(category.entries?.count ?? 0)")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let currentAmount {
                Text(currentAmount.formatted(.customCurrency()))
                    .foregroundColor(currentAmount >= 0 ? .green : .red)
            } else {
                Text("-")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    func sectionHeader(_ label: SavingsCategoryLabel) -> some View {
        let totalSum: Double = content.getTotalSumFor(label)
        let fractionOfAll: Double = content.getFractionPercentageFor(label)
        HStack(spacing: 0) {
            if label.rawValue != "" {
                Text(LocalizedStringKey(label.rawValue))
            } else {
                Text("Unlabeled")
            }
            Spacer()
            Group {
                Text(totalSum, format: .customCurrency())
                Text(" (" + String(format: "%.1f", 100 * fractionOfAll) + "%)")
            }
            .foregroundColor(totalSum >= 0 ? .green: .red)
        }
    }
    
    @ViewBuilder
    func savingsLabelSection(_ label: SavingsCategoryLabel) -> some View {
        Section(header: sectionHeader(label)) {
            ForEach(content.items.filter { $0.label == label.rawValue }) { category in
                NavigationLink(destination: SavingsCategoryListView(category: category)) {
                    categoryTile(category)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(SavingsCategoryLabel.allCases, id: \.self) { label in
                    let relevantCategories = content.items.filter { $0.label == label.rawValue }
                    if relevantCategories.count > 0 {
                        savingsLabelSection(label)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        entryContent.currentItem = nil
                        showAddEntryView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddEntryView) {
                SavingsEntryFormView(isPresented: $showAddEntryView, editor: SavingsEditor(entry: entryContent.currentItem))
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
            .navigationTitle("Savings")
        }
    }
}

struct SavingsView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsView()
    }
}
