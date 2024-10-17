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
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .opacity(isFocussed ? 0.2 : 0)
                        .tint(nil)
                }
            TextField("", text: $text)
                .textSelection(.disabled)
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
        .fixedSize()
        .lineLimit(1)
    }
    
    private static func format(value: Double) -> String {
        let formattedString = value.formatted(.customCurrency())
        return formattedString
    }

    private func formatText() {
        guard text.count <= self.maxLength else {
            text = prevText
            return
        }
        guard self.text != self.prevText else {
            return
        }
        
        var digits: String = text.filter { $0.isWholeNumber }
        let prevDigits: String = prevText.filter { $0.isWholeNumber }
        
        guard let p = Double(prevDigits), p > 0 || text.count > prevText.count else {
            text = prevText
            return
        }
        
        if prevText.count > text.count {
            // User has pressed the delete key
            digits = String(digits.dropLast())
        } else {
            // User has added some char to the text value
            // Check if the user has placed the cursor in an invalid position
            // If so, make sure the new character is appended to the text
            if digits.first != prevDigits.first {
                let f = digits.removeFirst()
                digits.append(f)
            }
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
        CurrencyInputField(value: $val).font(.largeTitle.bold())
    }
}

#Preview {
    PreviewView()
}
