//
//  SavingsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI
import Charts

struct SavingsDetailView: View {
    @State private var selectedElement: ValueTimeDataPoint?
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    
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
            Text("Last Month").tag(2592000)
            Text("Last Year").tag(31536000)
            Text("5 Years").tag(157680000)
            Text("Max").tag(-1)
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
//        .chartYAxis {
//            AxisMarks { value in
//                AxisGridLine()
//                AxisValueLabel(format: .currency(code: "EUR"))
//            }
//        }
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
                Text(netWorthToDisplay, format: .currency(code: "EUR"))
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
            Text(category.lastEntry?.amount.formatted(.currency(code: "EUR")) ?? "-")
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
    
    var scrollViewContent: some View {
        ScrollView {
            chartHeader
            savingsChart
            timeframePicker
            Divider()
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(content.items) { category in
                    savingsCategorySummaryTile(category)
                }
            }
            .padding()
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
