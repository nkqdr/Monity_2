//
//  RecurringTransactionsLineChart.swift
//  Monity
//
//  Created by Niklas Kuder on 03.03.23.
//

import SwiftUI
import Charts

struct RecurringTransactionsLineChart: View {
    @ObservedObject private var content: RecurringTransactionsViewModel
    @Binding var selectedElement: ValueTimeDataPoint?
    var displayMode: ChartMode
    
    init() {
        self.content = RecurringTransactionsViewModel.shared
        self.displayMode = .display
        self._selectedElement = .constant(nil)
    }
    
    init(selectedDataPoint: Binding<ValueTimeDataPoint?>) {
        self.content = RecurringTransactionsViewModel.shared
        self.displayMode = .interactive
        self._selectedElement = selectedDataPoint
    }
    
    enum ChartMode {
        case interactive
        case display
    }
    
    var chartBase: some View {
        Chart(content.chartDataPoints) {
            LineMark(x: .value("Date", $0.date), y: .value("Amount", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.stepEnd)
            if let selectedElement, selectedElement.id == $0.id {
                RuleMark(x: .value("Date", selectedElement.date))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
        }
        .chartYAxis(displayMode == .display ? .hidden : .automatic)
    }
    
    var interactiveChart: some View {
        chartBase
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
    }
    
    var body: some View {
        Group {
            if displayMode == .interactive {
                interactiveChart
            } else {
                chartBase
            }
        }
        .foregroundColor(.secondary)
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
            for dataIndex in content.chartDataPoints.indices {
                let nthDataDistance = content.chartDataPoints[dataIndex].date.distance(to: date)
                if abs(nthDataDistance) < minDistance {
                    minDistance = abs(nthDataDistance)
                    index = dataIndex
                }
            }
            if let index {
                return content.chartDataPoints[index]
            }
      }
      return nil
    }
}

struct RecurringTransactionsLineChart_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsLineChart()
    }
}
