//
//  BudgetWizard.swift
//  Monity
//
//  Created by Niklas Kuder on 11.07.24.
//

import SwiftUI

fileprivate struct CategoryBudgetLine: View {
    @ObservedObject var budgetDefinition: CategoryBudgetMap
    @FocusState.Binding var focusedField: Field?
    
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
                    .focused($focusedField, equals: .categoryBudget(budgetDefinition.id))
                
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
    @FocusState.Binding var focusedInput: Field?
    @ObservedObject var viewModel: BudgetWizardViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Category budgets")
                    .font(.largeTitle.bold())
                Text("Now, let’s allocate your monthly budget across your transaction categories. Feel free to enter the amount you plan to spend in each category for the month!")
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
            .padding(.vertical)
            ForEach(viewModel.budgetMaps) { budgetMap in
                CategoryBudgetLine(budgetDefinition: budgetMap, focusedField: $focusedInput)
            }
            .padding(.horizontal)
        }
    }
}

fileprivate struct WizardControls: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: Int
    var maxSelection: Int
    var save: () -> Void
    
    func handleBackward() {
        if selection > 1 {
            selection -= 1
        } else {
            dismiss()
        }
    }
    
    func handleForward() {
        if selection < maxSelection {
            selection += 1
        } else {
            save()
        }
    }
    
    var backIcon: String {
        if selection == 1 {
            return "xmark"
        }
        return "chevron.backward"
    }
    
    var forwardIcon: String {
        if selection == maxSelection {
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
                Label {
                    if selection == 1 {
                        Text("Cancel")
                    }
                } icon: {
                    Image(systemName: backIcon)
                }
                .padding(5)
            }
            .buttonStyle(.bordered)
            .tint(selection == 1 ? .red : nil)
            
            Spacer()
            
            Button {
                withAnimation {
                    handleForward()
                }
            } label: {
                Label {
                    if selection == maxSelection {
                        Text("Save")
                    }
                } icon: {
                    Image(systemName: forwardIcon)
                }
                .padding(5)
            }
            .buttonStyle(.bordered)
            .tint(selection == maxSelection ? .green : nil)
        }
        .padding()
    }
}

fileprivate struct MonthlyBudgetForm: View {
    @ObservedObject var viewModel: BudgetWizardViewModel
    @FocusState.Binding var focusedInput: Field?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Monthly budget")
                    .font(.largeTitle.bold())
                Text("To help you manage your finances effectively, please enter your desired monthly budget below.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                
                CurrencyInputField(value: $viewModel.tmpMonthlyBudget)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.green)
                    .focused($focusedInput, equals: .monthlyBudget)
                    .padding(.top)
            }
            .padding()
            .padding(.top)
        }
    }
}

fileprivate enum Field: Hashable {
    case monthlyBudget
    case categoryBudget(UUID)
}

struct BudgetWizard: View {
    @Environment(\.dismiss) var dismiss
    @FocusState fileprivate var focusedInput: Field?
    @State private var selectedPage: Int = 1
    @StateObject var viewModel = BudgetWizardViewModel()
    
    var body: some View {
        VStack {
            NavigationView {
                TabView(selection: $selectedPage) {
                    MonthlyBudgetForm(viewModel: viewModel, focusedInput: $focusedInput)
                        .tag(1)
                    
                    SplitBudgetView(focusedInput: $focusedInput, viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button {
                            focusedInput = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .onChange(of: selectedPage) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        focusedInput = nil
                    }
                }
                .onAppear {
                    // So that the user cannot horizontally scroll between TabView pages
                    UIScrollView.appearance().isScrollEnabled = false
                    focusedInput = .monthlyBudget
                }
            }
            
            WizardControls(selection: $selectedPage, maxSelection: 2) {
                print("Saving...")
                viewModel.save {
                    dismiss()
                }
            }
        }
        .alert(Text("Budgets don't match"), isPresented: $viewModel.showWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Save anyway") {
                viewModel.save(force: true) {
                    dismiss()
                }
            }
        } message: {
            Text("Your monthly budget is \(viewModel.tmpMonthlyBudget.formatted(.customCurrency())) while the sum of your category budgets is \(viewModel.categoryBudgetSum.formatted(.customCurrency())).\n\nThis may be an error, but you can also just save it like this.")
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
