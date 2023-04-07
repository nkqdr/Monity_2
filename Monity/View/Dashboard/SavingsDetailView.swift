//
//  SavingsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI
import Charts

struct SavingsDetailView: View {
    private let savingsProjectionYears: [Int] = [1, 5, 10, 25, 50]
    @State private var selectedElement: ValueTimeDataPoint?
    @State private var showHiddenCategories: Bool = false
    @State private var showAssetAllocation: Bool = false
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    @AppStorage("show_projections_in_savings_overview") private var showProjections: Bool = true
    
    var noCategories: some View {
        VStack {
            Text("No Savings categories defined.")
            Text("Go to Settings > Savings to define your categories.")
        }
        .foregroundColor(.secondary)
        .padding()
        .multilineTextAlignment(.center)
    }
    
    var timeframePicker: some View {
        // The picker holds the number of seconds for the selected timeframe.
        Picker("Timeframe", selection: $content.timeFrameToDisplay) {
            Text("picker.lastmonth").tag(2592000)
            Text("picker.sixmonths").tag(15552000)
            Text("picker.lastyear").tag(31536000)
            Text("picker.fiveyears").tag(157680000)
            Text("picker.max").tag(-1)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    var savingsChart: some View {
        Chart(content.filteredLineChartData) {
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.catmullRom)
            if let selectedElement, selectedElement.id == $0.id {
                RuleMark(x: .value("Date", selectedElement.date))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: content.minLineChartValue ... content.maxLineChartValue)
        .chartOverlay { proxy in
         GeometryReader { geo in
            Rectangle()
              .fill(.clear)
              .contentShape(Rectangle())
              .gesture(
                SpatialTapGesture()
                  .onEnded { value in
                    let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                    Haptics.shared.play(.medium)
                    if selectedElement?.date == element?.date {
                      // If tapping the same element, clear the selection.
                      selectedElement = nil
                    } else {
                        selectedElement = element
                    }
                  }
                  .exclusively(before: DragGesture()
                    .onChanged { value in
                        let newElement = findElement(location: value.location, proxy: proxy, geometry: geo)
                        if selectedElement == newElement {
                            return
                        }
                        selectedElement = newElement
                        Haptics.shared.play(.medium)
                    }
                    .onEnded { _ in
                        selectedElement = nil
                    })
              )
          }
        }
        .frame(height: 200)
        .foregroundColor(content.currentNetWorth >= 0 ? .green : .red)
        .padding(.horizontal)
//        .animation(.easeInOut, value: content.filteredLineChartData)
    }
    
    @ViewBuilder
    var chartHeader: some View {
        let netWorthToDisplay: Double = selectedElement != nil ? selectedElement!.value : content.currentNetWorth
        let timeToDisplay: Date = selectedElement != nil ? selectedElement!.date : Date()
        HStack {
            VStack(alignment: .leading) {
                Text(netWorthToDisplay, format: .customCurrency())
                    .font(.title2.bold())
                Text(timeToDisplay, format: .dateTime.year().month().day())
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    func savingsCategorySummaryTile(_ category: SavingsCategory) -> some View {
        let label = VStack(alignment: .leading) {
            Text(category.wrappedName).groupBoxLabelTextStyle()
            Text(category.lastEntry?.amount.formatted(.customCurrency()) ?? "-")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        let dataPoints: [ValueTimeDataPoint] = category.lineChartDataPoints(after: content.lowerBoundDate)
        let maxValue: Double = dataPoints.map { $0.value }.max() ?? 0
        GroupBox(label: label) {
            Chart(dataPoints) {
                AreaMark(x: .value("Date", $0.date), y: .value("Amount", $0.value))
                    .opacity(0.5)
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Date", $0.date), y: .value("Value", $0.value))
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .interpolationMethod(.catmullRom)
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .chartYScale(domain: 0 ... maxValue)
            .foregroundColor(category.lastEntry?.amount ?? 0 >= 0 ? .green : .red)
        }
        .groupBoxStyle(CustomGroupBox())
        .frame(minHeight: 200)
    }
    
    func categoryGridFor(_ categories: [SavingsCategory]) -> some View {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(categories) { category in
                savingsCategorySummaryTile(category)
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
        }
        .padding()
    }
    
    func getFutureDate(addedYears: Int) -> Date {
        let comps = DateComponents(year: addedYears)
        return Calendar.current.date(byAdding: comps, to: Date()) ?? Date()
    }
    
    var savingsProjections: some View {
        VStack(alignment: .leading) {
            Text("Future Projections").font(.footnote).foregroundColor(.secondary).padding(.bottom, 5)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(savingsProjectionYears, id: \.self) { yearAmount in
                        SavingsPredictionBox(yearAmount: yearAmount)
                            .frame(minWidth: 300, minHeight: 50)
                    }
                }
                .padding(.horizontal)
            }
            HStack {
                Text("Average change per year:")
                    .font(.footnote).foregroundColor(.secondary).padding(.top, 5)
                Spacer()
                Text(content.yearlySavingsRate, format: .customCurrency())
                    .font(.footnote).foregroundColor(content.yearlySavingsRate >= 0 ? .green : .red).padding(.top, 5)
            }
            .padding(.horizontal)
        }
    }
    
    var scrollViewContent: some View {
        ScrollView {
            chartHeader
            savingsChart
            timeframePicker
            if (showProjections) {
                Divider()
                savingsProjections
            }
            Divider()
            categoryGridFor(content.shownCategories)
        }
    }
    
    @ViewBuilder
    var hiddenCategoriesSheet: some View {
        NavigationView {
            ScrollView {
                categoryGridFor(content.hiddenCategories)
            }
            .navigationTitle("Hidden Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    var assetAllocationSheet: some View {
        NavigationView {
            AssetAllocationPieChart(relevantLabels: SavingsCategoryLabel.allCasesWithoutNone)
                .navigationTitle("Asset Allocation")
                .navigationBarTitleDisplayMode(.inline)
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
            hiddenCategoriesSheet
        }
        .sheet(isPresented: $showAssetAllocation) {
            assetAllocationSheet
        }
        .navigationTitle("Savings Overview")
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ValueTimeDataPoint? {
      // Figure out the X position by offseting gesture location with chart frame
      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
      // Use value(atX:) to find plotted value for the given X axis position.
      // Since FoodIntake chart plots `date` on the X axis, we'll get a Date back.
        if let date: Date = proxy.value(atX: relativeXPosition) {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for dataIndex in content.filteredLineChartData.indices {
                let nthDataDistance = content.filteredLineChartData[dataIndex].date.distance(to: date)
                if abs(nthDataDistance) < minDistance {
                    minDistance = abs(nthDataDistance)
                    index = dataIndex
                }
            }
            if let index {
                return content.filteredLineChartData[index]
            }
      }
      return nil
    }
}

struct WealthView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsDetailView()
    }
}
