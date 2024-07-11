//
//  CurrencyInputField.swift
//  Monity
//
//  Created by Niklas Kuder on 10.07.24.
//

import SwiftUI

struct CurrencyInputField: View {
    @Binding var value: Double
    @State private var text: String
    @State private var prevText: String
    
    init(value: Binding<Double>) {
        self._value = value
        self.text = Self.format(value: value.wrappedValue)
        self.prevText = Self.format(value: value.wrappedValue)
    }

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .onChange(of: text) { newValue in
                formatText()
                prevText = text
            }
            .onAppear {
                formatText()
                prevText = text
            }
            .tint(.clear)
    }
    
    private static func format(value: Double) -> String {
        let formattedString = value.formatted(.customCurrency())
        return formattedString
    }

    private func formatText() {
        var digits: String = text.filter { $0.isWholeNumber }
        
        if prevText.count > text.count, digits.count > 0 {
            digits = String(digits.dropLast())
        }
        
        // Convert the filtered text to a Double value
        let doubleValue = (Double(digits) ?? 0) / 100.0
        value = doubleValue
        
        text = Self.format(value: doubleValue)
    }
}

struct PreviewView: View {
    @State var val: Double = 0
    var body: some View {
        CurrencyInputField(value: $val)
    }
}

#Preview {
    PreviewView()
}
