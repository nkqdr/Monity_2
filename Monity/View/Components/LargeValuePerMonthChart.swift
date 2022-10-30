//
//  LargeValuePerMonthChart.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import SwiftUI
import Charts

struct LargeValuePerMonthChart: View {
    @Binding var selectedElement: ValueTimeDataPoint?
    @State private var ruleMarkOffset: Double = 0
    var valuePerMonthDataPoints: [ValueTimeDataPoint]
    var showAverageBar: Bool
    var average: Double
    var color: Color
    
    var body: some View {
        Chart(valuePerMonthDataPoints) {
            if showAverageBar {
                RuleMark(y: .value("Average", average))
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Ø \(average.formatted(.customCurrency()))")
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
                let currencyCode = UserDefaults.standard.string(forKey: "user_selected_currency")
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
                  .exclusively(before: DragGesture()
                    .onChanged { value in
                        ruleMarkOffset = Double(proxy.plotAreaSize.width) / Double(valuePerMonthDataPoints.count) / 2
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
        .frame(minHeight: 250)
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ValueTimeDataPoint? {
      // Figure out the X position by offseting gesture location with chart frame
      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
      // Use value(atX:) to find plotted value for the given X axis position.
      // Since FoodIntake chart plots `date` on the X axis, we'll get a Date back.
        if let date: Date = proxy.value(atX: relativeXPosition) {
          // Find the month for tapped date
          for dataPoint in valuePerMonthDataPoints {
              if dataPoint.date.isSameMonthAs(date) {
                  return dataPoint
              }
          }
      }
      return nil
    }
}
