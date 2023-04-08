//
//  SavingsCategoryTile.swift
//  Monity
//
//  Created by Niklas Kuder on 08.04.23.
//

import SwiftUI

struct SavingsCategoryTile: View {
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    var category: SavingsCategory
    
    private var currentAmount: Double? {
        category.lastEntry?.amount
    }
    
    private var groupBoxLabel: some View {
        NavigationGroupBoxLabel(title: LocalizedStringKey(category.wrappedName), subtitle: LocalizedStringKey("Associated entries: \(category.entries?.count ?? 0)"), labelStyle: .primary)
    }
    
    var body: some View {
        NavigationLink(destination: SavingsCategoryListView(category: category)) {
            GroupBox(label: groupBoxLabel) {
                HStack(alignment: .top) {
                    Spacer()
                    if let currentAmount {
                        Text(currentAmount.formatted(.customCurrency()))
                            .tintedBackground(currentAmount >= 0 ? .green : .red)
                    } else {
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .groupBoxStyle(CustomGroupBox())
            .contextMenu {
                Button {
                    withAnimation(.spring()) {
                        content.toggleHiddenFor(category)
                    }
                } label: {
                    if category.isHidden {
                        Label("Show", systemImage: "eye.fill")
                    } else {
                        Label("Hide", systemImage: "eye.slash.fill")
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
