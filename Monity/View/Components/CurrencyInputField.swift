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
    @FocusState private var isFocussed: Bool
    private let maxLength: Int = 16
    
    init(value: Binding<Double>) {
        self._value = value
        self.text = Self.format(value: value.wrappedValue)
        self.prevText = Self.format(value: value.wrappedValue)
    }

    var body: some View {
        ZStack(alignment: .leadingFirstTextBaseline) {
            Text(text)
                .hidden()
                .tintedBackground(backgroundOpacity: isFocussed ? 0.2 : 0, padding: 4)
            TextField("", text: $text)
                .focused($isFocussed)
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
                .padding(4)
        }
    }
    
    private static func format(value: Double) -> String {
        let formattedString = value.formatted(.customCurrency())
        return formattedString
    }

    private func formatText() {
        if text.count > self.maxLength {
            text = prevText
        }
        
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

fileprivate struct PreviewView: View {
    @State var val: Double = 0
    var body: some View {
        CurrencyInputField(value: $val)
    }
}

#Preview {
    PreviewView()
}
