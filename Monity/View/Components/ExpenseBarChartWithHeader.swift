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
    @State private var selectedElement: TimeSeriesTransactionData.DataPoint?
    @State private var dragGestureTick: Double = 0
    @State private var selectedLowerBoundDate: Date
    @State private var isDragging = false
    @ObservedObject private var timeSeriesData: TimeSeriesTransactionData
    @ObservedObject private var budgetsData: BudgetViewModel
    var showAverageBar: Bool
    var color: Color
    var alwaysShowYmarks: Bool
    private var showsExpenses: Bool?
    
    var data: TimeSeriesTransactionData.Data {
        self.timeSeriesData.data
    }
    
    init(
        category: TransactionCategory? = nil,
        isExpense: Bool? = nil,
        color: Color = .green,
        showAverageBar: Bool = false,
        alwaysShowYmarks: Bool = true
    ) {
        self.showsExpenses = isExpense
        self.timeSeriesData = TimeSeriesTransactionData(
            include: isExpense == nil ? .all : isExpense! ? .expense : .income,
            timeframe: .total,
            category: category
        )
        self.budgetsData = BudgetViewModel(for: category)
        self.color = color
        self.showAverageBar = showAverageBar
        self.alwaysShowYmarks = alwaysShowYmarks
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
        self._selectedLowerBoundDate = State(initialValue: oneYearAgo)
    }
    
    private var slicedData: [TimeSeriesTransactionData.DataPoint] {
        data.filter { $0.date > selectedLowerBoundDate && $0.date <= upperBoundDate}
    }
    
    private var slicedBudgetData: [BudgetViewModel.DateRangeDataPoint] {
        budgetsData.data.filter {
            ($0.endDate > selectedLowerBoundDate && $0.endDate <= upperBoundDate) || $0.startDate <= upperBoundDate && $0.startDate > selectedLowerBoundDate
        }
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
    
    func barChartOpacity(for dp: TimeSeriesTransactionData.DataPoint) -> CGFloat {
        let somethingIsSelected: Bool = selectedElement != nil
        let dpIsCurrentlySelected: Bool = somethingIsSelected && dp.id == selectedElement!.id
        if dpIsCurrentlySelected {
            return 1
        }
        // dp is not the currently selected data point
        if somethingIsSelected {
            return 0.3
        }
        // Nothing is currently selected
        return showAverageBar ? 0.3 : 1
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            chartHeader
            Chart {
                ForEach(slicedData) {
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
                    BarMark(x: .value("Month", $0.date, unit: .month), y: .value("Expenses", $0.value))
                        .foregroundStyle(color.gradient)
                        .opacity(barChartOpacity(for: $0))
                        .cornerRadius(5)
                }
                    ForEach(slicedBudgetData) {
                        RuleMark(
                            xStart: .value("Start", max($0.startDate, self.selectedLowerBoundDate)),
                            xEnd: .value("End", min($0.endDate, self.upperBoundDate)),
                            y: .value("Amount", $0.amount)
                        )
                        .foregroundStyle(color.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                    }
            }
            .chartYAxis {
                AxisMarks { value in
                    let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency)
                    AxisGridLine()
                    if selectedElement != nil || isDragging || alwaysShowYmarks {
                        AxisValueLabel(format: .currency(code: currencyCode ?? "EUR"))
                    }
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
                        let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                        Haptics.shared.play(.light)
                          if selectedElement?.date == element?.date {
                            // If tapping the same element, clear the selection.
                              withAnimation {
                                  selectedElement = nil
                              }
                          } else if selectedElement == nil && !alwaysShowYmarks {
                              withAnimation {
                                  selectedElement = element
                              }
                          } else {
                              withAnimation {
                                  selectedElement = element
                              }
                          }
                          
                      }
                        .exclusively(before: DragGesture().onChanged { value in
                            withAnimation {
                                isDragging = true
                            }
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
                                        Haptics.shared.play(.light)
                                    }
                                }
                            }
                        }.onEnded {_ in
                            withAnimation {
                                isDragging = false
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
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> TimeSeriesTransactionData.DataPoint? {
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
