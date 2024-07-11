//
//  BudgetWizard.swift
//  Monity
//
//  Created by Niklas Kuder on 11.07.24.
//

import SwiftUI

fileprivate struct SplitBudgetView: View {
    @FetchRequest(
        entity: TransactionCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)]
    ) private var allCategories: FetchedResults<TransactionCategory>
    
    var body: some View {
        ScrollView {
            ForEach(allCategories) { category in
                Text(category.wrappedName)
            }
        }
    }
}

struct BudgetWizard: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var limitInputIsFocussed: Bool
    @State private var tmpMonthlyLimit: Double = UserDefaults.standard.double(forKey: AppStorageKeys.monthlyLimit)
    @State private var showSplitBudgetView: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CurrencyInputField(value: $tmpMonthlyLimit)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.green)
                        .focused($limitInputIsFocussed)
                } header: {
                    Text("Monthly budget")
                }
                .listRowBackground(Color.clear)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    limitInputIsFocussed = true
                }
            }
            .navigationDestination(isPresented: $showSplitBudgetView) {
                SplitBudgetView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Continue") {
                        withAnimation {
                            showSplitBudgetView.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel, action: {
                        dismiss()
                    })
                }
            }
        }
    }
}

fileprivate struct PreviewView: View {
    @State var showSheet: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                showSheet.toggle()
            } label: {
                Text("Show sheet")
            }
        }
        .sheet(isPresented: $showSheet) {
            BudgetWizard()
        }
    }
}

#Preview {
    PreviewView()
        .environment(\.managedObjectContext, PersistenceController.previewContext)
}
