//
//  ExpenseBarChartWithHeader.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.23.
//

import SwiftUI
import Charts
import Accelerate

fileprivate struct CompactCurrencyAxisLabel: View {
    enum CurrencySymbolPlacement {
        case prefix
        case suffix
    }
    
    let value: Double
    let currencyCode: String

    var body: some View {
        let symbol = Self.currencySymbol(for: currencyCode)
        let placement = Self.getCurrencySymbolPlacement(for: currencyCode)

        let compact = value.formatted(.number
            .locale(Locale(identifier: "en_US"))
            .notation(.compactName))

        let label: String = {
            switch placement {
            case .prefix: return symbol + compact
            case .suffix: return compact + " " + symbol
            }
        }()

        Text(label)
    }

    private static func getCurrencySymbolPlacement(for currencyCode: String) -> CurrencySymbolPlacement {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode

        if let example = formatter.string(from: 1.0),
           let symbol = formatter.currencySymbol {
            return example.hasPrefix(symbol) ? .prefix : .suffix
        }

        return .suffix
    }

    private static func currencySymbol(for currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode

        if let _ = formatter.string(from: 1),
           let symbol = formatter.currencySymbol {
            return symbol
        }

        return currencyCode
    }
}

struct TransactionBarChart: View {
    typealias TimeSeriesGroup = (type: String, data: TimeSeriesTransactionData.Data)
    typealias TimeSeriesGroupElement = (expense: TimeSeriesTransactionData.DataPoint, income: TimeSeriesTransactionData.DataPoint, date: Date)
    
    @State private var selectedElement: TimeSeriesGroupElement?
    @State private var dragGestureTick: Double = 0
    @State private var selectedLowerBoundDate: Date
    @State private var isDragging = false
    @ObservedObject private var timeSeriesIncome: TimeSeriesTransactionData
    @ObservedObject private var timeSeriesExpenses: TimeSeriesTransactionData
    
    var groupedData: [TimeSeriesGroup] {
        return [
            (type: String(localized: "income.plural"), data: self.timeSeriesIncome.data),
            (type: String(localized: "Expenses"), data: self.timeSeriesExpenses.data)
        ]
    }

    init(
        category: TransactionCategory? = nil
    ) {
        self.timeSeriesIncome = TimeSeriesTransactionData(
            include: .income,
            timeframe: .total,
            category: category
        )
        self.timeSeriesExpenses = TimeSeriesTransactionData(
            include: .expense,
            timeframe: .total,
            category: category
        )
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(month: -6), to: Date())!
        self._selectedLowerBoundDate = State(initialValue: oneYearAgo)
    }

    private var slicedGroupedData: [(type: String, data: [TimeSeriesTransactionData.DataPoint])] {
        groupedData.map { (type: String, data: TimeSeriesTransactionData.Data) in
            (type: type, data: data.filter { $0.date > selectedLowerBoundDate && $0.date <= upperBoundDate})
        }
    }

    private var upperBoundDate: Date {
        Calendar.current.date(byAdding: DateComponents(month: 6), to: selectedLowerBoundDate)!
    }

    var timeframeString: String {
        (slicedGroupedData[0].data.first?.date.formatted(.dateTime.year().month()) ?? "") + " - " + (slicedGroupedData[0].data.last?.date.formatted(.dateTime.year().month()) ?? "")
    }

    var totalValue: (income: Double, expenses: Double) {
        (income: vDSP.sum(slicedGroupedData[0].data.map { $0.value }), expenses: vDSP.sum(slicedGroupedData[1].data.map { $0.value }))
    }

    @ViewBuilder
    var chartHeader: some View {
        if let selectedElement {
            VStack(alignment: .leading) {
                Text(selectedElement.date.formatted(.dateTime.year().month()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(selectedElement.expense.value, format: .customCurrency())
                        .font(.headline.bold())
                        .tintedBackground(.red)
                    Text(selectedElement.income.value, format: .customCurrency())
                        .font(.headline.bold())
                        .tintedBackground(.green)
                }
            }
        } else {
            VStack(alignment: .leading) {
                Group {
                    Text(timeframeString)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(totalValue.expenses, format: .customCurrency())
                        .font(.headline.bold())
                        .tintedBackground(.red)
                    Text(totalValue.income, format: .customCurrency())
                        .font(.headline.bold())
                        .tintedBackground(.green)
                }
            }
            .animation(.none, value: timeframeString)
        }
    }

    func barChartOpacity(for dp: TimeSeriesTransactionData.DataPoint) -> CGFloat {
        let somethingIsSelected: Bool = selectedElement != nil
        let dpIsCurrentlySelected: Bool = somethingIsSelected && dp.date.isSameMonthAs(selectedElement!.date)
        if dpIsCurrentlySelected {
            return 1
        }
        // dp is not the currently selected data point
        if somethingIsSelected {
            return 0.3
        }
        // Nothing is currently selected
        return 1
    }

    var body: some View {
        VStack(alignment: .leading) {
            chartHeader
            Chart {
                ForEach(slicedGroupedData, id: \.type) { group in
                    ForEach(group.data) {
                        BarMark(x: .value("Month", $0.date, unit: .month), y: .value("Amount", $0.value))
                            .opacity(barChartOpacity(for: $0))
                            .cornerRadius(5)
                    }
                    .foregroundStyle(by: .value("Type", group.type))
                    .position(by: .value("Type", group.type))
                }
            }
            .chartForegroundStyleScale([
                String(localized: "income.plural"): .green, String(localized: "Expenses"): .red
            ])
            .chartYAxis {
                AxisMarks { value in
                    if let doubleValue = value.as(Double.self) {
                        AxisGridLine()
                        AxisValueLabel {
                            let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency) ?? "EUR"
                            CompactCurrencyAxisLabel(value: doubleValue, currencyCode: currencyCode)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
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
                          let tappedDate: Date = element?.date ?? Date.distantPast
                          let selectedDate: Date = selectedElement?.date ?? Date.distantPast
                        Haptics.shared.play(.light)
                          if selectedDate.isSameMonthAs(tappedDate) {
                            // If tapping the same element, clear the selection.
                              withAnimation {
                                  selectedElement = nil
                              }
                          } else if selectedElement == nil {
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
                            let barWidth = Double(proxy.plotAreaSize.width) / Double(slicedGroupedData[0].data.count ) + 4
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
        }
    }

    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> TimeSeriesGroupElement? {
      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        var incomeDP: TimeSeriesTransactionData.DataPoint? = nil
        var expenseDP: TimeSeriesTransactionData.DataPoint? = nil
        if let date: Date = proxy.value(atX: relativeXPosition) {
            for dataPoint in slicedGroupedData[0].data {
              if dataPoint.date.isSameMonthAs(date) {
                  incomeDP = dataPoint
                  break
              }
            }
            for dataPoint in slicedGroupedData[1].data {
                if dataPoint.date.isSameMonthAs(date) {
                    expenseDP = dataPoint
                    break
                }
            }
            if let incomeDP, let expenseDP {
                return (expense: expenseDP, income: incomeDP, date: date)
            }
        }
      return nil
    }

    private func dragChartRight() -> Bool {
        if (slicedGroupedData[0].data.first?.date == groupedData[0].data.first?.date) {
            return false
        }
        let newVal = Calendar.current.date(byAdding: DateComponents(month: -1), to: selectedLowerBoundDate) ?? Date()
        if (slicedGroupedData[0].data.first?.date.isSameMonthAs(Calendar.current.date(byAdding: DateComponents(year: -1, month: 2), to: newVal) ?? Date()) ?? true ) {
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

struct ExpenseBarChartWithHeader: View {
    @State private var selectedElement: TimeSeriesTransactionData.DataPoint?
    @State private var dragGestureTick: Double = 0
    @State private var selectedLowerBoundDate: Date
    @State private var isDragging = false
    @ObservedObject private var timeSeriesData: TimeSeriesTransactionData
    var showAverageBar: Bool
    var color: Color
    var alwaysShowYmarks: Bool
    
    var data: TimeSeriesTransactionData.Data {
        self.timeSeriesData.data
    }
    
    init(
        category: TransactionCategory? = nil,
        isExpense: Bool,
        color: Color = .green,
        showAverageBar: Bool = false,
        alwaysShowYmarks: Bool = true
    ) {
        self.timeSeriesData = TimeSeriesTransactionData(
            include: isExpense ? .expense : .income,
            timeframe: .total,
            category: category
        )
        self.color = color
        self.showAverageBar = showAverageBar
        self.alwaysShowYmarks = alwaysShowYmarks
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
        self._selectedLowerBoundDate = State(initialValue: oneYearAgo)
    }
    
    private var slicedData: [TimeSeriesTransactionData.DataPoint] {
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
                BarMark(x: .value("Month", $0.date, unit: .month), y: .value("Expenses", $0.value))
                    .foregroundStyle(color.gradient)
                    .opacity(barChartOpacity(for: $0))
                    .cornerRadius(5)
            }
            .chartYAxis {
                AxisMarks { value in
                    if let doubleValue = value.as(Double.self) {
                        AxisGridLine()
                        if selectedElement != nil || isDragging || alwaysShowYmarks {
                            let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency) ?? "USD"
                            AxisValueLabel {
                                CompactCurrencyAxisLabel(value: doubleValue, currencyCode: currencyCode)
                            }
                        }
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
