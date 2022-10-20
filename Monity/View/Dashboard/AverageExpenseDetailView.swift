//
//  AverageExpenseDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI
import Charts

struct AverageExpenseDetailView: View {
    @State private var showAverageBar: Bool = false
    @State private var selectedElement: ValueTimeDataPoint?
    @State private var ruleMarkOffset: Double = 0
    @State private var showMonthSummarySheet: Bool = false
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    var barChart: some View {
        Chart(content.monthlyExpenseDataPoints) {
            if showAverageBar {
                RuleMark(y: .value("Average", content.averageExpenses))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Ø \(content.averageExpenses.formatted(.currency(code: "EUR")))")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
            }
            if let selectedElement, selectedElement.id == $0.id {
                RuleMark(x: .value("Month", selectedElement.date))
                    .offset(x: ruleMarkOffset)
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
            BarMark(x: .value("Month", $0.date, unit: .month), y: .value("Expenses", $0.value))
                .foregroundStyle(.red.opacity(showAverageBar ? 0.3 : 1).gradient)
        }
        .padding(.top, 25)
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel(format: .currency(code: "EUR"))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.narrow))
            }
        }
        .chartOverlay { proxy in
            ruleMarkOffset = Double(proxy.plotAreaSize.width) / Double(content.monthlyExpenseDataPoints.count) / 2
        return GeometryReader { geo in
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
        .frame(minHeight: 250)
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Over the last year").groupBoxLabelTextStyle(.secondary)
                ZStack(alignment: .topLeading) {
                    if let selectedElement {
                        VStack(alignment: .leading) {
                            Text(selectedElement.date, format: .dateTime.year().month())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(selectedElement.value, format: .currency(code: "EUR"))
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                        }
                    } else {
                        Text("Total: \(content.totalExpensesThisYear.formatted(.currency(code: "EUR")))")
                            .font(.headline.bold())
                    }
                    barChart
                        .padding(.vertical)
                }
            }
            .listRowBackground(Color.clear)
            Section {
                if selectedElement != nil {
                    HStack {
                        Button("View month summary") {
                            showMonthSummarySheet.toggle()
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                }
                Toggle("Show average mark", isOn: $showAverageBar)
            }
            Text("Categories").groupBoxLabelTextStyle(.secondary)
                .padding(.top)
            ForEach(content.expenseCategoryRetroDataPoints) { dataPoint in
                HStack {
                    VStack(alignment: .leading) {
                        Text(dataPoint.category.wrappedName)
                            .fontWeight(.bold)
                        Text("\(dataPoint.numTransactions) transactions")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(dataPoint.total, format: .currency(code: "EUR"))
                            .fontWeight(.semibold)
                        Text("Ø\(dataPoint.average.formatted(.currency(code: "EUR"))) p.m.")
                            .font(.caption2)
                    }
                    .foregroundColor(Color.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $showMonthSummarySheet) {
            if let selectedElement {
                NavigationView {
                    MonthSummaryView(monthDate: selectedElement.date)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Close") {
                                    showMonthSummarySheet.toggle()
                                }
                            }
                        }
                }
            }
        }
        .navigationTitle("Expenses")
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ValueTimeDataPoint? {
      // Figure out the X position by offseting gesture location with chart frame
      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
      // Use value(atX:) to find plotted value for the given X axis position.
      // Since FoodIntake chart plots `date` on the X axis, we'll get a Date back.
        if let date: Date = proxy.value(atX: relativeXPosition) {
          // Find the month for tapped date
          for dataPoint in content.monthlyExpenseDataPoints {
              if dataPoint.date.isSameMonthAs(date) {
                  return dataPoint
              }
          }
      }
      return nil
    }
}

struct AverageExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AverageExpenseDetailView()
    }
}
