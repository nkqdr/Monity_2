//
//  CurrentMonthDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI
import Charts

struct CurrentMonthDetailView: View {
    @AppStorage("monthly_limit") private var monthlyLimit: Double = 0
    @State private var remainingAmount: Double = 0
    @State var selectedElement: ValueTimeDataPoint?
    @StateObject private var content = MonthlyOverviewViewModel()
    
    var overviewHeader: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("Days left:")
                            .font(.system(size: 18, weight: .semibold))
                        Text("\(content.remainingDays)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text("Budget:")
                            .font(.system(size: 18, weight: .semibold))
                        Text(remainingAmount, format: .currency(code: "EUR"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(remainingAmount >= 0 ? .green : .red)
                    }
                }
                Spacer()
                BudgetBattery(monthlyLimit: monthlyLimit, alreadySpent: content.spentThisMonth)
            }
            Divider()
            HStack {
                Text("Predicted total expenses:")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Text(content.predictedTotalSpendings, format: .currency(code: "EUR"))
                    .foregroundColor(content.predictedTotalSpendings > monthlyLimit ? .red : .green)
            }
        }
        .padding(.vertical, 5)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    var cashFlowChart: some View {
        let minValue: Double = (content.cashFlowData.map { $0.value }.min() ?? 10) * 1.2
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
                  Text(lastValue, format: .currency(code: "EUR"))
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
                  Text(selectedElement.value, format: .currency(code: "EUR"))
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
    
    var body: some View {
        List {
            Section {
                overviewHeader
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Income").groupBoxLabelTextStyle()
                    CurrencyPieChart(values: content.incomeDataPoints, backgroundColor: .clear, centerLabel: content.earnedThisMonth, emptyString: "No registered income for this month.")
                }
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Expenses").groupBoxLabelTextStyle()
                    CurrencyPieChart(values: content.expenseDataPoints, backgroundColor: .clear, centerLabel: content.spentThisMonth, emptyString: "No registered expenses for this month.")
                }
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Current cashflow").groupBoxLabelTextStyle()
                        .padding(.top, 8)
                    if content.cashFlowData.count > 1 {
                        cashFlowChart
                    } else {
                        HStack {
                            Spacer()
                            Text("No registered transactions for this month.")
                                .groupBoxLabelTextStyle(.secondary)
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
        .navigationTitle("Current Month")
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

struct CurrentMonthDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentMonthDetailView()
    }
}
