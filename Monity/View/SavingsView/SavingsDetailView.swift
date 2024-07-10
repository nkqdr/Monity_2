//
//  SavingsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI
import Charts

fileprivate struct SavingsCategoryTile: View {
    @StateObject var category: SavingsCategory
    @Binding var addWithCategory: SavingsCategory?
    @Binding var editCategory: SavingsCategory?
    
    private var currentAmount: Double? {
        category.lastEntry?.amount
    }
    
    private var groupBoxLabel: some View {
        NavigationGroupBoxLabel(
            title: LocalizedStringKey(category.wrappedName),
            subtitle: LocalizedStringKey(category.lastEntry?.wrappedDate.formatted(.dateTime.year().month().day()) ?? ""),
            labelStyle: .primary
        )
    }
    
    var body: some View {
        NavigationLink(destination: SavingsCategoryListProxy(category: category)) {
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
                if !category.isHidden {
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
                }
                Divider()
                Button(role: category.isHidden ? .cancel : .destructive) {
                    withAnimation(.spring()) {
                        let _ = SavingsCategoryStorage.main.update(
                            category,
                            isHidden: !category.isHidden
                        )
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

fileprivate struct SavingsCategoryList: View {
    @StateObject private var viewModel: SavingsCategoryGridVM
    @State private var addWithCategory: SavingsCategory? = nil
    @State private var editCategory: SavingsCategory? = nil
    
    init(isHidden: Bool) {
        self._viewModel = StateObject(wrappedValue: SavingsCategoryGridVM(isHidden: isHidden))
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(viewModel.categories) { category in
                SavingsCategoryTile(category: category, addWithCategory: $addWithCategory, editCategory: $editCategory)
            }
        }
        .addSavingsEntrySheet(category: $addWithCategory)
        .editSavingsCategorySheet(category: $editCategory)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

fileprivate struct SavingsProjections: View {
    @StateObject private var viewModel = SavingsPredictionViewModel()
    @AppStorage(AppStorageKeys.showSavingsProjections) private var showProjections: Bool = true
    private let savingsProjectionYears: [Int] = [1, 5, 10, 25, 50]
    
    var horizontalScrollView: some View {
        VStack(alignment: .leading) {
            Text("Future Projections").textCase(.uppercase).font(.footnote).foregroundColor(.secondary).padding(.bottom, 1)
                .padding(.horizontal, 30)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(savingsProjectionYears, id: \.self) { yearAmount in
                        SavingsPredictionBox(yearAmount: yearAmount)
                            .frame(minWidth: 300, minHeight: 50)
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal)
            }
            HStack(alignment: .bottom) {
                Text("Average change per year:")
                    .font(.footnote).foregroundColor(.secondary).padding(.top, 5)
                Spacer()
                Text(viewModel.yearlySavingsRate, format: .customCurrency())
                    .font(.footnote).foregroundColor(viewModel.yearlySavingsRate >= 0 ? .green : .red).padding(.top, 1)
            }
            .padding(.horizontal, 30)
        }
    }
    
    var body: some View {
        if (showProjections) {
            horizontalScrollView
                .padding(.vertical)
        }
    }
}

fileprivate struct SavingsPredictionBox: View {
    @EnvironmentObject private var viewModel: SavingsPredictionViewModel
    var yearAmount: Int
    
    private var projection: Double {
        viewModel.getXYearProjection(yearAmount)
    }
    
    private var accentColor: Color {
        projection >= 0 ? .green : .red
    }
    
    private var percentageChange: Double {
        guard viewModel.currentNetWorth > 0 else { return 0 }
        return (projection / viewModel.currentNetWorth - 1).round(to: 3)
    }
    
    private var predictionDate: Date {
        Calendar.current.date(byAdding: DateComponents(year: yearAmount), to: Date()) ?? Date()
    }
    
    private var arrowIcon: String {
        projection >= 0 ? "arrow.up.forward.square.fill" : "arrow.down.forward.square.fill"
    }
    
    private var label: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("\(yearAmount) Years").groupBoxLabelTextStyle()
                Text(predictionDate, format: .dateTime.year().month())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Label(percentageChange.formatted(.percent), systemImage: arrowIcon)
                .foregroundColor(accentColor)
                .font(.subheadline)
        }
    }
    
    var body: some View {
        GroupBox(label: label) {
            HStack {
                Spacer()
                Text(projection, format: .customCurrency())
                    .fontWeight(.bold)
                    .tintedBackground(accentColor)
            }
        }
        .groupBoxStyle(CustomGroupBox())
        .frame(maxHeight: 100)
    }
}

struct SavingsDetailView: View {
    @State private var showHiddenCategories: Bool = false
    @State private var showAssetAllocation: Bool = false
    @StateObject private var content = SavingsCategoryViewModel.shared
    
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
            SavingsCategoryList(isHidden: false)
        }
    }
    
    var body: some View {
        ListBase {
            if content.items.isEmpty {
                noCategories
            } else {
                scrollViewContent
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
                        SavingsCategoryList(isHidden: true)
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
        .navigationTitle("Savings Overview")
    }
}

struct WealthView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsDetailView()
    }
}
