//
//  TransactionCategoryFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

fileprivate let availableIcons: [String] = [
    "folder.fill", "paperplane.fill", "tray.fill", "archivebox.fill", "doc.fill",
    "book.fill", "graduationcap.fill", "gym.bag.fill", "trophy.fill", "keyboard.fill"
]

fileprivate struct IconSelectionView: View {
    var name: String
    var isActive: Bool = false
    
    var iconColor: Color {
        isActive ? .accentColor : .secondary
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(iconColor, lineWidth: isActive ? 5 : 0)
            .background(RoundedRectangle(cornerRadius: 10).fill(iconColor.opacity(0.2)))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                Image(systemName: name)
                    .font(.system(size: 20))
                    .foregroundStyle(isActive ? .primary : .secondary)
            }
    }
}

struct TransactionCategoryFormView: View {
    @FocusState private var focusNameField
    @Environment(\.dismiss) var dismiss
    @StateObject var editor: TransactionCategoryEditor
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category name", text: $editor.name)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .font(.largeTitle.bold())
                    .focused($focusNameField)
                Section {
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                        ForEach(availableIcons, id: \.self) { name in
                            IconSelectionView(
                                name: name,
                                isActive: name == editor.selectedIcon
                            )
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                Haptics.shared.play(.soft)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if editor.selectedIcon == name {
                                        editor.selectedIcon = nil
                                    } else {
                                        editor.selectedIcon = name
                                    }
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                } header: {
                    Text("Icon")
                }
                .listRowBackground(Color.clear)
                
            }
            .onAppear {
                self.focusNameField = true
            }
            .navigationTitle(editor.navigationFormTitle)
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
                    .disabled(!editor.isValid)
                }
            }
        }
    }
}

struct TransactionCategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategoryFormView(editor: TransactionCategoryEditor())
    }
}
