//
//  BudgetInput.swift
//  Monity
//
//  Created by Niklas Kuder on 15.07.24.
//

import SwiftUI

fileprivate struct BudgetInputBase: View {
    @Binding var value: Double
    @State private var hasBudget: Bool
    
    init(value: Binding<Double>) {
        self._value = value
        self.hasBudget = value.wrappedValue != 0
    }
    
    var body: some View {
        Group {
            if self.hasBudget {
                CurrencyInputField(value: $value)
                    .font(.title2.bold())
                
                Button {
                    self.hasBudget = false
                } label: {
                    Image(systemName: "xmark")
                }
                .clipShape(Circle())
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button {
                    self.hasBudget = true
                } label: {
                    Image(systemName: "plus")
                }
                .clipShape(Circle())
                .buttonStyle(.bordered)
            }
        }
        .controlSize(.small)
        .onChange(of: hasBudget) { newValue in
            if !newValue {
                self.value = 0
            }
        }
    }
}

struct BudgetInput: View {
    @Binding var value: Double
    private var title: LocalizedStringKey?
    
    init(_ title: LocalizedStringKey? = nil, value: Binding<Double>) {
        self._value = value
        self.title = title
    }
    
    var body: some View {
        HStack {
            if let title = self.title {
                Text(title)
            }
            Spacer()
            BudgetInputBase(value: $value)
        }
    }
}
