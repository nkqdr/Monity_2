//
//  SavingsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI
import Charts

struct SavingsDetailView: View {
    @State private var selectedElement: ValueTimeDataPoint?
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    
    var noCategories: some View {
        VStack {
            Text("No Savings categories defined.")
            Text("Go to Settings > Savings to define your categories.")
        }
        .foregroundColor(.secondary)
        .padding()
        .multilineTextAlignment(.center)
    }
    
    var timeframePicker: some View {
        Picker("Timeframe", selection: $content.timeFrameToDisplay) {
            Text("Last Month").tag(2592000)
            Text("Last Year").tag(31536000)
            Text("5 Years").tag(157680000)
            Text("Max").tag(-1)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    var savingsChart: some View {
        Chart(content.filteredLineChartData) {
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.catmullRom)
            if let selectedElement, selectedElement.id == $0.id {
                RuleMark(x: .value("Date", selectedElement.date))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
        }
        .chartYAxis(.hidden)
//        .chartYAxis {
//            AxisMarks { value in
//                AxisGridLine()
//                AxisValueLabel(format: .currency(code: "EUR"))
//            }
//        }
        .chartYScale(domain: content.minLineChartValue ... content.maxLineChartValue)
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
        .frame(height: 200)
        .foregroundColor(content.percentChangeInLastYear >= 0 ? .green : .red)
        .padding()
//        .animation(.easeInOut, value: content.filteredLineChartData)
    }
    
    var scrollViewContent: some View {
        ScrollView {
            savingsChart
            timeframePicker
            Divider()
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(content.items) { category in
                    GroupBox(label: Text(category.wrappedName).groupBoxLabelTextStyle()) {
                        Circle()
                            .frame(width: 20)
                            .foregroundColor(.red)
                    }
                    .groupBoxStyle(CustomGroupBox())
                    .frame(minHeight: 200)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    var mainContent: some View {
        if content.items.isEmpty {
            noCategories
        } else {
            scrollViewContent
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            mainContent
        }
        .navigationTitle("Savings Overview")
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
            for dataIndex in content.filteredLineChartData.indices {
                let nthDataDistance = content.filteredLineChartData[dataIndex].date.distance(to: date)
                if abs(nthDataDistance) < minDistance {
                    minDistance = abs(nthDataDistance)
                    index = dataIndex
                }
            }
            if let index {
                return content.filteredLineChartData[index]
            }
      }
      return nil
    }
}

struct CustomGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            Spacer()
            HStack {
                Spacer()
                configuration.content
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemGroupedBackground)))
    }
}

struct WealthView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsDetailView()
    }
}
