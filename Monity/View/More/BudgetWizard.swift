//
//  BudgetWizard.swift
//  Monity
//
//  Created by Niklas Kuder on 11.07.24.
//

import SwiftUI

fileprivate struct CategoryBudgetLine: View {
    @ObservedObject var budgetDefinition: CategoryBudgetMap
    
    var body: some View {
        HStack {
            Label {
                Text(budgetDefinition.category.wrappedName)
            } icon: {
                if let icon = budgetDefinition.category.iconName {
                    Image(systemName: icon)
                }
            }
            Spacer()
            if budgetDefinition.hasBudget {
                CurrencyInputField(value: $budgetDefinition.budget)
                    .font(.title2.bold())
                
                Button {
                    budgetDefinition.hasBudget = false
                } label: {
                    Image(systemName: "xmark")
                }
                .clipShape(Circle())
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button {
                    budgetDefinition.hasBudget = true
                } label: {
                    Image(systemName: "plus")
                }
                .clipShape(Circle())
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

fileprivate struct SplitBudgetView: View {
    @ObservedObject var viewModel: BudgetWizardViewModel
    
    var body: some View {
        ScrollView {
            Text(viewModel.tmpMonthlyBudget, format: .customCurrency())
            ForEach(viewModel.budgetMaps) { budgetMap in
                CategoryBudgetLine(budgetDefinition: budgetMap)
            }
            .padding(.horizontal)
        }
    }
}

fileprivate struct WizardControls: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: Int
    var maxIndex: Int
    var save: () -> Void
    
    func handleBackward() {
        if selection > 0 {
            selection -= 1
        } else {
            dismiss()
        }
    }
    
    func handleForward() {
        if selection < maxIndex {
            selection += 1
        } else {
            save()
        }
    }
    
    var backIcon: String {
        if selection == 0 {
            return "xmark"
        }
        return "chevron.backward"
    }
    
    var forwardIcon: String {
        if selection == maxIndex {
            return "checkmark"
        }
        return "chevron.forward"
    }
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    handleBackward()
                }
            } label: {
                Image(systemName: backIcon)
                    .padding(5)
            }
            .buttonStyle(.bordered)
            .tint(selection == 0 ? .red : nil)
            
            Spacer()
            
            Button {
                withAnimation {
                    handleForward()
                }
            } label: {
                Image(systemName: forwardIcon)
                    .padding(5)
            }
            .buttonStyle(.bordered)
            .tint(selection == maxIndex ? .green : nil)
        }
        .padding()
    }
}

fileprivate enum Field: Hashable {
    case monthlyBudget
    case categoryBudget(UUID)
}

struct BudgetWizard: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedInput: Field?
    @State private var selectedPage: Int = 0
    @StateObject var viewModel = BudgetWizardViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedPage) {
                Form {
                    Section {
                        CurrencyInputField(value: $viewModel.tmpMonthlyBudget)
                            .font(.largeTitle.bold())
                            .foregroundStyle(.green)
                            .focused($focusedInput, equals: .monthlyBudget)
                    } header: {
                        Text("Monthly budget")
                    }
                    .listRowBackground(Color.clear)
                }
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button {
                                focusedInput = nil
                            } label: {
                                Image(systemName: "keyboard.chevron.compact.down")
                            }
                        }
                    }
                }
                .onAppear {
                    focusedInput = .monthlyBudget
                }
                .tag(0)
                
                SplitBudgetView(viewModel: viewModel)
                    .tag(1)
            }
            .onAppear {
                UIScrollView.appearance().isScrollEnabled = false
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            WizardControls(selection: $selectedPage, maxIndex: 1) {
                print("Saving...")
                viewModel.save {
                    dismiss()
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
