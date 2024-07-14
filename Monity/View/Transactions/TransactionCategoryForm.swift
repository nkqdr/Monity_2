//
//  TransactionCategoryForm.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import SwiftUI

fileprivate let availableIcons: [String] = [
    "cart.fill", "car.fill", "bus.fill", "bag.fill", "house.fill", "fuelpump.fill",
    "graduationcap.fill", "gym.bag.fill", "pawprint.fill", "hammer.fill",
    "wrench.adjustable.fill", "tag.fill", "paperplane.fill", "tray.fill",
    "archivebox.fill", "doc.fill", "folder.fill", "shippingbox.fill",
    "book.fill", "trophy.fill", "keyboard.fill",
    "sun.max.fill", "moon.fill", "sparkles", "drop.fill", "music.note", "mic.fill",
    "rectangle.3.group.fill", "checkmark.seal.fill", "heart.fill", "shield.checkered",
    "flag.fill", "phone.fill", "video.fill", "envelope.fill",
    "ellipsis.circle.fill", "basket.fill", "creditcard.fill",
    "pianokeys", "printer.fill", "handbag.fill",
    "suitcase.fill", "lightbulb.fill", "powerplug.fill", "balloon.2.fill",
    "bed.double.fill", "mountain.2.fill", "lock.fill", "wifi", "display", "airplane",
    "bandage.fill", "leaf.fill",
    "carrot.fill", "birthday.cake.fill", "atom"
]

fileprivate struct IconSelectionView: View {
    var name: String
    var isActive: Bool = false
    
    var iconColor: Color {
        isActive ? .accentColor : .secondary
    }
    
    var body: some View {
        Image(systemName: name)
            .font(.system(size: 20))
            .frame(width: 50, height: 50)
            .tintedBackground(isActive ? .accentColor : .secondary, cornerRadius: 8, backgroundOpacity: isActive ? 0.25 : 0.1)
    }
}

struct TransactionCategoryForm: View {
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
