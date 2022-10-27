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
                Text(currentAmount.formatted(.currency(code: "EUR")))
                    .foregroundColor(.green)
            } else {
                Text("-")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    func savingsLabelSection(_ label: SavingsCategoryLabel) -> some View {
        Section(label.rawValue != "" ? label.rawValue : "Unlabeled") {
            ForEach(content.items.filter { $0.label == label.rawValue }) { category in
                NavigationLink(destination: EmptyView()) {
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
                        showAddEntryView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
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
