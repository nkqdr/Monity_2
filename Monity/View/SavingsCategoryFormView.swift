//
//  SavingsCategoryFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import SwiftUI

fileprivate struct SavingsLabelStyle: ViewModifier {
    @Binding var selection: SavingsCategoryLabel
    var label: SavingsCategoryLabel
    
    func body(content: Content) -> some View {
        content
            .padding(5)
            .padding(.horizontal, 10)
            .tintedBackground(
                selection == label ? label.color : .secondary,
                cornerRadius: 10,
                backgroundOpacity: selection == label ? 0.2 : 0.05
            )
            .onTapGesture {
                Haptics.shared.play(.soft)
                withAnimation {
                    if selection == label {
                        selection = .none
                    } else {
                        selection = label
                    }
                }
            }
            
    }
}

fileprivate struct SavingsLabelPicker: View {
    @Binding var selection: SavingsCategoryLabel
    
    var body: some View {
        HStack {
            Spacer()
            Text("Liquid")
                .modifier(SavingsLabelStyle(selection: $selection, label: .liquid))
            Spacer()
            Text("Saved")
                .modifier(SavingsLabelStyle(selection: $selection, label: .saved))
            Spacer()
            Text("Invested")
                .modifier(SavingsLabelStyle(selection: $selection, label: .invested))
            Spacer()
        }
    }
}

struct SavingsCategoryFormView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var editor: SavingsCategoryEditor
    @FocusState var focusNameField: Bool
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category name", text: $editor.name)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .font(.largeTitle.bold())
                    .focused($focusNameField)
                Section {
                    SavingsLabelPicker(selection: $editor.label)
                } header: {
                    Text("Label")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                Section {
                    ZStack(alignment: .trailing) {
                        TextField("0", value: $editor.interestRate, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 115)
                            .onChange(of: editor.interestRate) {
                                editor.interestRate = Double(String($0).prefix(5))!
                            }
                        Text("% p.a.").foregroundStyle(.secondary).padding(.trailing, 6)
                    }
                    .font(.headline)
                    .padding()
                } header: {
                    Text("Interest Rate")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .onAppear {
                focusNameField = true
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editor.save()
                        dismiss()
                    }
                    .disabled(editor.disableSave)
                }
            }
        }
    }
}

struct SavingsCategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsCategoryFormView(editor: SavingsCategoryEditor())
    }
}
