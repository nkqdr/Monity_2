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
    @Binding var dataPoints: [ValueTimeDataPoint]
    @State private var localDataPoints: [ValueTimeDataPoint]
    var showHeader: Bool
    var showArea: Bool
    var currentNetWorth: Double = 0
    
    init(selectedElement: ValueTimeDataPoint? = nil, dataPoints: Binding<[ValueTimeDataPoint]>, currentNetWorth: Double, showHeader: Bool = true, showArea: Bool = false) {
        self._dataPoints = Binding(projectedValue: dataPoints)
        self._localDataPoints = State(initialValue: dataPoints.wrappedValue)
        self.showHeader = showHeader
        self.showArea = showArea
        self.selectedElement = selectedElement
        self.currentNetWorth = currentNetWorth
    }
    
    init(selectedElement: ValueTimeDataPoint? = nil, dataPoints: Binding<[ValueTimeDataPoint]>, showHeader: Bool = true, showArea: Bool = false) {
        self.init(
            selectedElement: selectedElement,
            dataPoints: dataPoints,
            currentNetWorth: dataPoints.wrappedValue.last?.value ?? 0,
            showHeader: showHeader,
            showArea: showArea
        )
    }
    
    private var minYValue: Double {
        if localDataPoints.isEmpty {
            return 0
        }
        return localDataPoints.map { $0.value }.min()!
    }
    
    private var maxYValue: Double {
        localDataPoints.map { $0.value }.max() ?? 0
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
    
    @ViewBuilder
    var actualChart: some View {
        Chart(localDataPoints) {
            if showArea {
                AreaMark(
                    x: .value("Date", $0.date),
                    yStart: .value("Amount", minYValue),
                    yEnd: .value("AmountEnd", $0.animate ? $0.value : minYValue)
                )
                    .opacity(0.5)
                    .interpolationMethod(.monotone)
            }
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.animate ? $0.value : minYValue))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.monotone)
            if minYValue < 0 {
                RuleMark(y: .value("Zero", 0))
                    .foregroundStyle(.secondary)
            }
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
                    Haptics.shared.play(.light)
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
                        Haptics.shared.play(.light)
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
            if showHeader {
                chartHeader
            }
            actualChart
        }
        .onChange(of: self.dataPoints) { dps in
            self.selectedElement = nil
            self.localDataPoints = dps
            animateLineChart()
        }
        .onAppear {
            animateLineChart()
        }
    }
    
    private func animateLineChart() {
        for (index, _) in self.localDataPoints.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.005) {
                if (index < self.localDataPoints.count) {
                    withAnimation(.easeInOut) {
                        self.localDataPoints[index].animate = true
                    }
                }
            }
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
            for dataIndex in self.localDataPoints.indices {
                let nthDataDistance = dataPoints[dataIndex].date.distance(to: date)
                if abs(nthDataDistance) < minDistance {
                    minDistance = abs(nthDataDistance)
                    index = dataIndex
                }
            }
            if let index {
                return self.localDataPoints[index]
            }
      }
      return nil
    }
}

struct SavingsLineChart: View {
    @StateObject private var viewModel = SavingsLineChartViewModel()
    
    var body: some View {
        VStack {
            SavingsDPLineChart(dataPoints: $viewModel.lineChartDataPoints, currentNetWorth: viewModel.currentNetWorth)
            // The picker holds the number of seconds for the selected timeframe.
            Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                ForEach(SavingsLineChartViewModel.possibleTimeframeLowerBounds) { config in
                    Text(LocalizedStringKey(config.label)).tag(config.tagValue)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedTimeframe) { _ in
                Haptics.shared.play(.soft)
            }
            
        }
        .padding(.horizontal)
    }
}

struct SavingsLineChart_Previews: PreviewProvider {
    static var previews: some View {
        SavingsLineChart()
    }
}
