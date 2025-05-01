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
    @State private var showFocusedBackground: Bool = false
    @FocusState private var isFocused: Bool
    private var maxDigits: Int

    init(value: Binding<Double>, maxDigits: Int? = nil) {
        self._value = value
        let initialText = Self.format(value: value.wrappedValue)
        self.text = initialText
        self.prevText = initialText
        self.maxDigits = maxDigits ?? 11
    }

    var body: some View {
        ZStack(alignment: .leadingFirstTextBaseline) {
            Text(text)
                .hidden()
                .padding(.horizontal, showFocusedBackground ? 4 : 0)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .opacity(showFocusedBackground ? 0.2 : 0)
                        .tint(nil)
                }
            TextField("", text: $text)
                .focused($isFocused)
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
                .padding(.horizontal, showFocusedBackground ? 4 : 0)
                .padding(.vertical, 4)
        }
        .onChange(of: isFocused) { newValue in
            withAnimation {
                showFocusedBackground = newValue
            }
        }
        .fixedSize()
        .lineLimit(1)
    }
    
    private static func format(value: Double) -> String {
        let formattedString = value.formatted(.customCurrency())
        return formattedString
    }

    private func formatText() {
        var digits: String = text.filter { $0.isWholeNumber }
        
        if digits.count > self.maxDigits {
            text = prevText
            return
        }
        
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
