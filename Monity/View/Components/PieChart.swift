//
//  PieChart.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct PieChart<S>: View where S: ViewModifier {
    public let values: [Double]
    public var colors: [Color]
    public var backgroundColor: Color = .clear
    public var showSliceLabels: Bool = false
    public var labelStyle: S
    public var widthFraction: CGFloat = 1
//    public var innerRadiusFraction: CGFloat
    
    @Binding var activeIndex: Int
    
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: String(format: "%.0f%%", value * 100 / sum), color: self.colors[i]))
            endDeg += degrees
        }
        return tempSlices
    }
    
    var body: some View {
        GeometryReader { geometry in
            let minSize = min(geometry.size.width, geometry.size.height)
            ZStack{
                ForEach(0..<values.count, id: \.self){ i in
                    PieSliceView(pieSliceData: slices[i], showLabels: showSliceLabels, labelModifier: labelStyle)
                        .scaleEffect(activeIndex == i ? 1.08 : 1)
                        .animation(.spring(), value: activeIndex)
                }
                .gesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            Haptics.shared.play(.medium)
                            let radius = 0.5 * widthFraction * geometry.size.width
                            let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                            var radians = Double(atan2(diff.x, diff.y))
                            if (radians < 0) {
                                radians = 2 * Double.pi + radians
                            }

                            for (i, slice) in slices.enumerated() {
                                if (radians < slice.endAngle.radians) {
                                    activeIndex = activeIndex == i ? -1 : i
                                    break
                                }
                            }
                        }
                )
            }
//            .foregroundColor(Color.white)
            .frame(width: minSize, height: minSize)
        }
        .aspectRatio(1, contentMode: .fit)
        .background(backgroundColor)
    }
}

extension PieChart where S == EmptyModifier {
    init(values: [Double], colors: [Color], backgroundColor: Color = .clear, showSliceLabels: Bool = false, activeIndex: Binding<Int>) {
        self.values = values
        self.colors = colors
        self._activeIndex = activeIndex
        self.backgroundColor = backgroundColor
        self.showSliceLabels = showSliceLabels
        self.labelStyle = EmptyModifier()
    }
}

struct PieSliceView<LabelStyle>: View where LabelStyle: ViewModifier {
    var pieSliceData: PieSliceData
    var showLabels: Bool
    var labelModifier: LabelStyle
    
    var midRadians: Double {
        return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
    }
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    
                    let center = CGPoint(x: width * 0.5, y: height * 0.5)
                    
                    path.move(to: center)
                    
                    path.addArc(
                        center: center,
                        radius: width * 0.5,
                        startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                        endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                        clockwise: false)
                    
                }
                .fill(pieSliceData.color.gradient)
                if showLabels {
                    Text(pieSliceData.text)
                        .position(
                            x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(midRadians)),
                            y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(midRadians))
                        )
                        .foregroundColor(Color.white)
                        .modifier(labelModifier)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var text: String
    var color: Color
}









//struct PieChart_Previews: PreviewProvider {
//    static var previews: some View {
//        PieChart()
//    }
//}
