//
//  EditableDeletableItemList.swift
//  Monity
//
//  Created by Niklas Kuder on 25.10.22.
//

import SwiftUI

struct EditableDeletableItemList<ListItem, ListContent, SheetContent>: View where ListContent: View, SheetContent: View {
    typealias CreateFunc = () -> Void
    typealias EditFunc = (ListItem) -> Void
    typealias DeleteFunc = (ListItem) -> Void
    typealias ListViewContent = (@escaping CreateFunc, @escaping EditFunc, @escaping DeleteFunc) -> ListContent
    typealias SheetViewContent = (Binding<Bool>, ListItem?) -> SheetContent
    
    @State private var showAddItemSheet: Bool = false
    @ObservedObject private var viewModel: ItemListViewModel<ListItem>
    
    let content: ListViewContent
    let sheetContent: SheetViewContent
    let includeAddInNavigationBar: Bool
    
    init(
        viewModel: ItemListViewModel<ListItem>,
        includeAddInNavigationBar: Bool = false,
        @ViewBuilder content: @escaping ListViewContent,
        @ViewBuilder sheetContent: @escaping SheetViewContent
    ) {
        self.viewModel = viewModel
        self.content = content
        self.sheetContent = sheetContent
        self.includeAddInNavigationBar = includeAddInNavigationBar
    }
    
    func showEditSheetForListItem(_ category: ListItem) {
        viewModel.currentItem = category
        showAddItemSheet.toggle()
    }
    
    func handleCreateAttempt() {
        viewModel.currentItem = nil
        showAddItemSheet.toggle()
    }
    
    var body: some View {
        List {
            content(handleCreateAttempt, showEditSheetForListItem, viewModel.deleteItem)
        }
        .sheet(isPresented: $showAddItemSheet) {
            sheetContent($showAddItemSheet, viewModel.currentItem)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: showAddItemSheet) { newValue in
            if !newValue {
                viewModel.currentItem = nil
            }
        }
        .toolbar {
            if includeAddInNavigationBar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handleCreateAttempt) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
