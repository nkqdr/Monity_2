//
//  MonthYearPicker.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import SwiftUI

struct MonthYearPicker: View {
    var titleKey: LocalizedStringKey?
    @Binding var dateSelection: DateComponents
    
    var body: some View {
        let currentYear: Int = Calendar.current.component(.year, from: Date())
        return GeometryReader { proxy in
            VStack(alignment: .leading) {
                if let title = titleKey {
                    Text(title)
                }
                HStack(spacing: 0) {
                    Picker(selection: $dateSelection.wrappedMonth, label: Text("")) {
                        ForEach(1 ..< 13) { index in
                            Text(Calendar.current.monthSymbols[index-1]).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: proxy.size.width/2, height: proxy.size.height, alignment: .center)
                    .compositingGroup()
                    .clipped()
                    Picker(selection: $dateSelection.wrappedYear, label: Text("")) {
                        ForEach(1900 ..< currentYear+1, id: \.self) { index in
                            Text(String(index)).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: proxy.size.width/2, height: proxy.size.height, alignment: .center)
                    .compositingGroup()
                    .clipped()
                }
            }
        }
    }
}

struct MonthYearPicker_Previews: PreviewProvider {
    static var previews: some View {
        MonthYearPicker(dateSelection: .constant(DateComponents()))
    }
}
