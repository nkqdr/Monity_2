//
//  ViewExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import SwiftUI

enum GroupBoxLabelStyle {
    case primary
    case secondary
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    static func customCurrency<Value>() -> FloatingPointFormatStyle<Value>.Currency where Value : BinaryFloatingPoint {
        let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency)
        return .currency(code: currencyCode ?? Locale.current.currency?.identifier ?? "USD")
    }
}

extension View {
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
        
        
    func deleteSwipeAction(callback: @escaping () -> Void) -> some View {
        self.swipeActions(edge: .trailing) {
            Button(action: callback) {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
    
    func editSwipeAction(callback: @escaping () -> Void) -> some View {
        self.swipeActions(edge: .leading) {
            Button(action: callback) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.indigo)
        }
    }
    
    func sync<T:Equatable>(_ published:Binding<T>, with binding:Binding<T>, delay: Double = 0) -> some View {
        self
            .onChange(of: published.wrappedValue) { published in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    binding.wrappedValue = published
                }
            }
            .onChange(of: binding.wrappedValue) { binding in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    published.wrappedValue = binding
                }
            }
    }
    
    @ViewBuilder
    func groupBoxLabelTextStyle(_ style: GroupBoxLabelStyle = .primary) -> some View {
        switch style {
        case .primary:
            self.font(.headline).bold()
        case .secondary:
            self.font(.subheadline).foregroundColor(.secondary)
        }
    }
    
    func onlyHideContextMenu<T: View>(@ViewBuilder content: @escaping () -> T) -> some View {
        self.contextMenu {
            Button {
                // Do nothing because contextMenu closes automatically
            } label: {
                Label("Hide", systemImage: "eye.slash.fill")
            }
        } preview: {
            content()
        }
    }
    
    func tintedBackground(_ tint: Color? = .accentColor, cornerRadius: CGFloat = 5, backgroundOpacity: Double = 0.1) -> some View {
        self.foregroundColor(tint)
            .padding(5)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(tint)
                    .opacity(backgroundOpacity)
            }
    }
    
    func monthYearSelectorSheet(_ isPresented: Binding<Bool>, selection: Binding<DateComponents>, onApply: @escaping () -> Void = {}) -> some View {
        self.sheet(isPresented: isPresented) {
            MonthYearPickerForm(selection: selection, isPresented: isPresented, onApply: onApply)
                .presentationDetents([.height(350)])
        }
    }
}
