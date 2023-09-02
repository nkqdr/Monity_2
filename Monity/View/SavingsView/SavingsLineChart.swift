//
//  SavingsLineChart.swift
//  Monity
//
//  Created by Niklas Kuder on 08.04.23.
//

import SwiftUI
import Charts

struct SavingsDPLineChart: View {
    @State private var selectedElement: ValueTimeDataPoint?
    var dataPoints: [ValueTimeDataPoint]
    var currentNetWorth: Double = 0
    
    init(selectedElement: ValueTimeDataPoint? = nil, dataPoints: [ValueTimeDataPoint], currentNetWorth: Double) {
        self.dataPoints = dataPoints
        self.selectedElement = selectedElement
        self.currentNetWorth = currentNetWorth
    }
    
    init(selectedElement: ValueTimeDataPoint? = nil, dataPoints: [ValueTimeDataPoint]) {
        self.init(
            selectedElement: selectedElement,
            dataPoints: dataPoints,
            currentNetWorth: dataPoints.last?.value ?? 0
        )
    }
    
    private var minYValue: Double {
        dataPoints.map { $0.value }.min() ?? 0
    }
    
    private var maxYValue: Double {
        dataPoints.map { $0.value }.max() ?? 0
    }
    
    @ViewBuilder
    var chartHeader: some View {
        let netWorthToDisplay: Double = selectedElement != nil ? selectedElement!.value : currentNetWorth
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
    }
    
    var actualChart: some View {
        Chart(dataPoints) {
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.monotone)
            if let selectedElement, selectedElement.id == $0.id {
                RuleMark(x: .value("Date", selectedElement.date))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: minYValue ... maxYValue)
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
        .foregroundColor(currentNetWorth >= 0 ? .green : .red)
    }
    
    var body: some View {
        VStack {
            chartHeader
            actualChart
        }
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
            for dataIndex in dataPoints.indices {
                let nthDataDistance = dataPoints[dataIndex].date.distance(to: date)
                if abs(nthDataDistance) < minDistance {
                    minDistance = abs(nthDataDistance)
                    index = dataIndex
                }
            }
            if let index {
                return dataPoints[index]
            }
      }
      return nil
    }
}

struct SavingsLineChart: View {
    @StateObject private var viewModel = SavingsLineChartViewModel()
    
    var body: some View {
        VStack {
            SavingsDPLineChart(dataPoints: viewModel.lineChartDataPoints, currentNetWorth: viewModel.currentNetWorth)
            // The picker holds the number of seconds for the selected timeframe.
            Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                ForEach(SavingsLineChartViewModel.possibleTimeframeLowerBounds) { config in
                    Text(LocalizedStringKey(config.label)).tag(config.tagValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
}

struct SavingsLineChart_Previews: PreviewProvider {
    static var previews: some View {
        SavingsLineChart()
    }
}
