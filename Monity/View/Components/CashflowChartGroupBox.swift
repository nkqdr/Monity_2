//
//  CashflowChartGroupBox.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import SwiftUI
import Charts

struct CashflowChartGroupBox: View {
    @ObservedObject private var content: MonthCashflowCalculator
    @State private var selectedElement: ValueTimeDataPoint?
    var date: Date
    
    init(date: Date = Date()) {
        self.date = date
        self.content = MonthCashflowCalculator(date: date)
    }
    
    var body: some View {
        GroupBox(label: Text("Current cashflow").groupBoxLabelTextStyle()) {
            if content.cashFlowData.count > 1 {
                actualChart
            } else {
                HStack {
                    Spacer()
                    Text("No registered transactions for this month.")
                        .multilineTextAlignment(.center)
                        .groupBoxLabelTextStyle(.secondary)
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
    
    @ViewBuilder
    var actualChart: some View {
        let minValue: Double = min(0, (content.cashFlowData.map { $0.value }.min() ?? 10))
        let absMaxValue: Double = (content.cashFlowData.map { abs($0.value) }.max() ?? 10)
        Chart(content.cashFlowData) {
            AreaMark(x: .value("Date", $0.date), y: .value("Amount", $0.value))
                .opacity(0.5)
                .interpolationMethod(.catmullRom)
            LineMark(x: .value("Date", $0.date), y: .value("Amount", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
                .symbol {
                    Circle()
                        .frame(width: 8)
                }
        }
        .chartYAxis() {
            AxisMarks { value in
                if value.as(Double.self) == 0 {
                    AxisGridLine()
                }
            }
        }
        .chartYScale(domain: minValue ... absMaxValue)
        .padding(.top, 50)
        .padding(.bottom, 8)
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
                      setSelectedElement(nil)
                    } else {
                      setSelectedElement(element)
                    }
                  }
                  .exclusively(before: DragGesture()
                    .onChanged { value in
                        let newElement = findElement(location: value.location, proxy: proxy, geometry: geo)
                        if selectedElement == newElement {
                            return
                        }
                        setSelectedElement(newElement)
                        Haptics.shared.play(.medium)
                    }
                    .onEnded { _ in
                        setSelectedElement(nil)
                    })
              )
          }
        }
        .chartBackground { proxy in
          ZStack(alignment: .topLeading) {
              if selectedElement == nil {
                  let lastValue: Double = content.cashFlowData.last?.value ?? 0
                  Text(lastValue, format: .customCurrency())
                      .foregroundColor(lastValue >= 0 ? .green : .red)
                      .font(.title3.bold())
              }
            GeometryReader { geo in
              if let selectedElement {
                // Map date to chart X position
                  let startPositionX = proxy.position(forX: selectedElement.date) ?? 0
                // Offset the chart X position by chart frame
                let midStartPositionX = startPositionX + geo[proxy.plotAreaFrame].origin.x
                let lineHeight = geo[proxy.plotAreaFrame].maxY
                let boxWidth: CGFloat = 85
                let boxOffset = max(0, min(geo.size.width - boxWidth, midStartPositionX - boxWidth / 2))

                // Draw the scan line
                Rectangle()
                  .fill(.quaternary)
                  .frame(width: 2, height: lineHeight)
                  .position(x: midStartPositionX, y: lineHeight / 2)

                // Draw the data info box
                VStack(alignment: .leading) {
                  Text("\(selectedElement.date, format: .dateTime.month().day())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                  Text(selectedElement.value, format: .customCurrency())
                    .font(.headline.bold())
                    .foregroundColor(.primary)
                }
                .frame(width: boxWidth, alignment: .leading)
                .background { // some styling
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                        .padding([.leading, .trailing], -8)
                        .padding([.top, .bottom], -4)
                }
                .offset(x: boxOffset)
              }
            }
          }
          .foregroundColor(nil)
        }
        .foregroundColor(content.cashFlowData.last?.value ?? 0 < 0 ? .red : .green)
        .frame(minHeight: 180)
    }
    
    func setSelectedElement(_ value: ValueTimeDataPoint?) {
        selectedElement = value
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ValueTimeDataPoint? {
      // Figure out the X position by offseting gesture location with chart frame
      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
      // Use value(atX:) to find plotted value for the given X axis position.
      // Since FoodIntake chart plots `date` on the X axis, we'll get a Date back.
      if let date = proxy.value(atX: relativeXPosition) as Date? {
        // Find the closest date element.
        var minDistance: TimeInterval = .infinity
        var index: Int? = nil
        for dataIndex in content.cashFlowData.indices {
            let nthDataDistance = content.cashFlowData[dataIndex].date.distance(to: date)
            if abs(nthDataDistance) < minDistance {
                minDistance = abs(nthDataDistance)
                index = dataIndex
            }
        }
        if let index {
            return content.cashFlowData[index]
        }
      }
      return nil
    }
}

struct CashflowChart_Previews: PreviewProvider {
    static var previews: some View {
        CashflowChartGroupBox()
    }
}
