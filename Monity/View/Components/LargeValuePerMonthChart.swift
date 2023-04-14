//
//  LargeValuePerMonthChart.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import SwiftUI
import Charts

struct LargeValuePerMonthChart: View {
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    @Binding var selectedElement: ValueTimeDataPoint?
    @State private var ruleMarkOffset: Double = 0
    @State private var dragGestureTick: Double = 0
    var showAverageBar: Bool
    
    private var color: Color {
        content.showingExpenses ? .red : .green
    }
    
    private var valuePerMonthDataPoints: [ValueTimeDataPoint] {
        content.barChartDataPoints
    }
    
    var body: some View {
        Chart(valuePerMonthDataPoints) {
            if showAverageBar {
                RuleMark(y: .value("Average", content.averageValue))
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Ø \(content.averageValue.formatted(.customCurrency()))")
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
        .padding(.top, 25)
        .chartYAxis {
            AxisMarks { value in
                let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency)
                AxisGridLine()
                AxisValueLabel(format: .currency(code: currencyCode ?? "EUR"))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
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
                    ruleMarkOffset = Double(proxy.plotAreaSize.width) / Double(valuePerMonthDataPoints.count) / 2
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
                        let barWidth = Double(proxy.plotAreaSize.width) / Double(valuePerMonthDataPoints.count) + 4
                        let dragDiff = value.location.x - value.startLocation.x
                        let dragAmount = (dragDiff / barWidth).rounded()
                        if (dragAmount != dragGestureTick) {
                            let direction = dragAmount - dragGestureTick
                            dragGestureTick = dragAmount
                            if (direction != 1.0 && direction != -1.0) {
                                return
                            }
                            if (content.drag(direction: direction)) {
                                Haptics.shared.play(.medium)
                            }
                        }
                    }.onEnded { value in
                        content.handleDragEnd()
                    })
              )
          }
        }
        .frame(minHeight: 250)
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ValueTimeDataPoint? {
      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date: Date = proxy.value(atX: relativeXPosition) {
          for dataPoint in valuePerMonthDataPoints {
              if dataPoint.date.isSameMonthAs(date) {
                  return dataPoint
              }
          }
      }
      return nil
    }
}
