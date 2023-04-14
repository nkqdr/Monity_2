//
//  MonthYearPickerForm.swift
//  Monity
//
//  Created by Niklas Kuder on 12.04.23.
//

import SwiftUI

struct MonthYearPickerForm: View {
    @Binding var selection: DateComponents
    @Binding var isPresented: Bool
    @State private var internalSelection: DateComponents
    var label: LocalizedStringKey
    var onApply: () -> Void
    
    init(_ label: LocalizedStringKey = "Selected month", selection: Binding<DateComponents>, isPresented: Binding<Bool>, onApply: @escaping () -> Void) {
        self._selection = selection
        self._internalSelection = State(initialValue: selection.wrappedValue)
        self._isPresented = isPresented
        self.label = label
        self.onApply = onApply
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding([.top, .horizontal])
            MonthYearPicker(dateSelection: $internalSelection)
                .frame(height: 150)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
//            Button("Today") {
//                withAnimation(.spring()) {
//                    internalSelection = Calendar.current.dateComponents([.month, .year], from: Date())
//                }
//            }
//            .buttonStyle(.bordered)
            Spacer()
            HStack {
                Button("Reset", role: .destructive) {
                    isPresented = false
                    withAnimation(.spring()) {
                        selection = Calendar.current.dateComponents([.month, .year], from: Date())
                    }
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Apply") {
                    isPresented = false
                    withAnimation(.spring()) {
                        selection = internalSelection
                    }
                    onApply()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
