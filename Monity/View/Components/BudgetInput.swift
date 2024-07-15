//
//  BudgetInput.swift
//  Monity
//
//  Created by Niklas Kuder on 15.07.24.
//

import SwiftUI

struct BudgetInput: View {
    @Binding var value: Double
    @State private var hasBudget: Bool
    private var title: LocalizedStringKey?
    
    init(_ title: LocalizedStringKey? = nil, value: Binding<Double>) {
        self._value = value
        self.hasBudget = value.wrappedValue != 0
        self.title = title
    }
    
    var body: some View {
        HStack {
            if let title = self.title {
                Text(title)
            }
            Spacer()
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
        .onChange(of: hasBudget) { newValue in
            if !newValue {
                self.value = 0
            }
        }
    }
}
