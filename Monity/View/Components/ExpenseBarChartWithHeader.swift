//
//  ExpenseBarChartWithHeader.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.23.
//

import SwiftUI
import Charts
import Accelerate

struct ExpenseBarChartWithHeader: View {
    @State private var selectedElement: ValueTimeDataPoint?
    @State private var ruleMarkOffset: Double = 0
    @State private var dragGestureTick: Double = 0
    @State private var selectedLowerBoundDate: Date
    var data: [ValueTimeDataPoint]
    var showAverageBar: Bool
    var color: Color
    
    init(data: [ValueTimeDataPoint], showAverageBar: Bool = false, color: Color = .green) {
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
        self.data = data
        self.color = color
        self.showAverageBar = showAverageBar
        self._selectedLowerBoundDate = State(initialValue: oneYearAgo)
    }
    
    private var slicedData: [ValueTimeDataPoint] {
        data.filter { $0.date > selectedLowerBoundDate && $0.date <= upperBoundDate}
    }
    
    private var upperBoundDate: Date {
        Calendar.current.date(byAdding: DateComponents(year: 1), to: selectedLowerBoundDate)!
    }
    
    private var averageValue: Double {
        vDSP.mean(slicedData.map { $0.value })
    }
    
    var timeframeString: String {
        (slicedData.first?.date.formatted(.dateTime.year().month()) ?? "") + " - " + (slicedData.last?.date.formatted(.dateTime.year().month()) ?? "")
    }
    
    var totalValue: Double {
        vDSP.sum(slicedData.map { $0.value})
    }
    
    @ViewBuilder
    var chartHeader: some View {
        if let selectedElement {
            VStack(alignment: .leading) {
                Text(selectedElement.date.formatted(.dateTime.year().month()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(selectedElement.value, format: .customCurrency())
                    .font(.headline.bold())
                    .foregroundColor(.primary)
            }
        } else {
            VStack(alignment: .leading) {
                Group {
                    Text(timeframeString)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                Text(totalValue, format: .customCurrency())
                    .font(.headline.bold())
                    .foregroundColor(.primary)
            }
            .animation(.none, value: timeframeString)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            chartHeader
            Chart(slicedData) {
                if showAverageBar {
                    RuleMark(y: .value("Average", averageValue))
                        .foregroundStyle(color)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Ø \(averageValue.formatted(.customCurrency()))")
                                .font(.footnote)
                                .foregroundColor(color)
                        }
                }
                if let selectedElement, selectedElement.id == $0.id {
                    RuleMark(x: .value("Month", selectedElement.date))
                        .offset(x: ruleMarkOffset)
                        .foregroundStyle(Color.secondary)
                        .lineStyle(StrokeStyle(lineWidth: 1))
                }
                BarMark(x: .value("Month", $0.date, unit: .month), y: .value("Expenses", $0.value))
                    .foregroundStyle(color.opacity(showAverageBar ? 0.3 : 1).gradient)
            }
            .chartYAxis {
                AxisMarks { value in
                    let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency)
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: currencyCode ?? "EUR"))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            }
            .chartOverlay { proxy in
             GeometryReader { geo in
                Rectangle()
                  .fill(.clear)
                  .contentShape(Rectangle())
                  .gesture(
                    SpatialTapGesture()
                      .onEnded { value in
                          let monthDiff = Calendar.current.dateComponents([.month], from: slicedData.first!.date, to: slicedData.last!.date).month ?? 1
                        ruleMarkOffset = Double(proxy.plotAreaSize.width) / Double(monthDiff) / 2
                        let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                        Haptics.shared.play(.medium)
                        if selectedElement?.date == element?.date {
                          // If tapping the same element, clear the selection.
                          selectedElement = nil
                        } else {
                            selectedElement = element
                        }
                      }
                        .exclusively(before: DragGesture().onChanged { value in
                            let barWidth = Double(proxy.plotAreaSize.width) / Double(slicedData.count) + 4
                            let dragDiff = value.location.x - value.startLocation.x
                            let dragAmount = (dragDiff / barWidth).rounded()
                            if (dragAmount != dragGestureTick) {
                                let direction = dragAmount - dragGestureTick
                                dragGestureTick = dragAmount
                                if (direction != 1.0 && direction != -1.0) {
                                    return
                                }
                                withAnimation {
                                    if (drag(direction: direction)) {
                                        Haptics.shared.play(.medium)
                                    }
                                }
                            }
                        })
                  )
              }
            }
            .onChange(of: data) { newValue in
                selectedElement = nil
            }
        }
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ValueTimeDataPoint? {
      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date: Date = proxy.value(atX: relativeXPosition) {
          for dataPoint in slicedData {
              if dataPoint.date.isSameMonthAs(date) {
                  return dataPoint
              }
          }
      }
      return nil
    }
    
    private func dragChartRight() -> Bool {
        if (slicedData.first?.date == data.first?.date) {
            return false
        }
        let newVal = Calendar.current.date(byAdding: DateComponents(month: -1), to: selectedLowerBoundDate) ?? Date()
        if (slicedData.first?.date.isSameMonthAs(Calendar.current.date(byAdding: DateComponents(year: -1, month: 2), to: newVal) ?? Date()) ?? true ) {
            return false
        }
        selectedLowerBoundDate = newVal
        return true
    }
    
    private func dragChartLeft() -> Bool {
        if (upperBoundDate.isSameMonthAs(Date())) {
            return false
        }
        selectedLowerBoundDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: selectedLowerBoundDate) ?? Date()
        return true
    }
    
    private func drag(direction: Double) -> Bool {
        if (direction > 0) {
            return dragChartRight()
        } else {
            return dragChartLeft()
        }
    }
}
