//
//  SavingsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI
import Charts

struct SavingsDetailView: View {
    @State private var showHiddenCategories: Bool = false
    @State private var showAssetAllocation: Bool = false
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    @ObservedObject private var entryManager = SavingsEntryManager()
    
    var noCategories: some View {
        VStack {
            Text("No Savings categories defined.")
            Text("Go to Settings > Savings to define your categories.")
        }
        .foregroundColor(.secondary)
        .padding()
        .multilineTextAlignment(.center)
    }
    
    var categorySectionHeader: some View {
        HStack {
            Text("Categories")
                .textCase(.uppercase)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
            Button {
                entryManager.editor = SavingsEditor(entry: nil)
                entryManager.showSheet.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding(.vertical, 1)
        .padding(.horizontal)
    }
    
    var scrollViewContent: some View {
        ScrollView {
            SavingsLineChart()
            SavingsProjections()
            categorySectionHeader
                .padding(.horizontal)
                .padding(.top)
            SavingsCategoryList(categories: content.shownCategories)
        }
    }
    
    var body: some View {
        ListBase {
            if content.items.isEmpty {
                noCategories
            } else {
                scrollViewContent
                    .environmentObject(entryManager)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showHiddenCategories.toggle() } label: {
                        Label("Hidden Categories", systemImage: "eye.slash.fill")
                    }
                    Button { showAssetAllocation.toggle() } label: {
                        Label("Asset Allocation", systemImage: "chart.pie.fill")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showHiddenCategories) {
            NavigationView {
                ListBase {
                    ScrollView {
                        SavingsCategoryList(categories: content.hiddenCategories)
                    }
                }
                .navigationTitle("Hidden Categories")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showAssetAllocation) {
            NavigationView {
                AssetAllocationPieChart()
                    .navigationTitle("Asset Allocation")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $entryManager.showSheet) {
            SavingsEntryFormView(isPresented: $entryManager.showSheet, editor: entryManager.editor)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .navigationTitle("Savings Overview")
    }
}

struct WealthView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsDetailView()
    }
}
