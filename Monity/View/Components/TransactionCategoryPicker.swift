//
//  TransactionCategoryPicker.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import SwiftUI
import Accelerate

fileprivate struct TagView: Layout {
    var spacing: CGFloat = 10
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let subviewWidth: CGFloat = vDSP.sum(subviews.map {
            Double($0.sizeThatFits(proposal).width)
        })
        let totalSubviews = subviews.count
        let totalWidth = (CGFloat(totalSubviews) * self.spacing) + ((subviewWidth / 2) * 1.05)
        return .init(width: totalWidth, height: proposal.height ?? 0)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let row1Y: CGFloat = 0
        let row2Y: CGFloat = (subviews.map {
            $0.sizeThatFits(proposal).height
        }.max() ?? 0) + spacing
        var row1X: CGFloat = 0
        var row2X: CGFloat = 0
        var currentY: CGFloat = row1Y
        
        subviews.forEach { view in
            let viewSize = view.sizeThatFits(proposal)
            
            let x: CGFloat = currentY == row1Y ? row1X : row2X
            view.place(at: CGPoint(x: x, y: currentY), proposal: proposal)
            if currentY == row1Y {
                row1X += (viewSize.width + spacing)
            } else {
                row2X += (viewSize.width + spacing)
            }
            if row1X <= row2X {
                currentY = row1Y
            } else {
                currentY = row2Y
            }
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func buttonStyle(for isSelected: Bool) -> some View {
        if (isSelected) {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

fileprivate struct CategoryLabel: View {
    @ObservedObject var category: TransactionCategory
    @Binding var selectedCategory: TransactionCategory?
    
    private var isSelected: Bool {
        category == selectedCategory
    }
    
    var body: some View {
        Button {
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
            Haptics.shared.play(.soft)
        } label: {
            Label {
                Text(category.wrappedName)
            } icon: {
                if let icon = category.iconName {
                    Image(systemName: icon).imageScale(.small)
                }
            }
        }
        .buttonStyle(for: isSelected)
    }
}

func sortedCategoriesByLikelihood(
    categories: [TransactionCategory],
    for amount: Double,
    isExpense: Bool
) -> [TransactionCategory] {
    return categories.sorted { catA, catB in
        let scoreA = averageDistance(from: amount, in: catA.transactionArray, isExpense: isExpense)
        let scoreB = averageDistance(from: amount, in: catB.transactionArray, isExpense: isExpense)
        return scoreA < scoreB // lower distance = higher likelihood
    }
}

private func averageDistance(
    from amount: Double,
    in transactions: [Transaction],
    isExpense: Bool
) -> Double {
    let matching = transactions.filter { $0.isExpense == isExpense }
    
    guard !matching.isEmpty else {
        // Penalize categories that don’t match the type at all
        return Double.greatestFiniteMagnitude
    }
    let totalDistance = vDSP.mean(matching.map { abs($0.amount - amount )})
    
    return totalDistance
}

struct TransactionCategoryPicker: View {
    @FetchRequest(
        entity: TransactionCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)]
    ) private var allCategories: FetchedResults<TransactionCategory>
    @Binding var selection: TransactionCategory?
    @Binding var userSelectedAmount: Double
    @Binding var userSelectedIsExpense: Bool
    @State private var showAddCategory: Bool = false
    
    init(
        selection: Binding<TransactionCategory?>,
        userSelectedAmount: Binding<Double>? = nil,
        userSelectedIsExpense: Binding<Bool>? = nil
    ) {
        self._selection = selection
        self._userSelectedAmount = userSelectedAmount ?? .constant(-1)
        self._userSelectedIsExpense = userSelectedIsExpense ?? .constant(false)
    }
    
    private var sortedCategories: [TransactionCategory] {
        sortedCategoriesByLikelihood(
            categories: Array(allCategories),
            for: userSelectedAmount,
            isExpense: userSelectedIsExpense
        )
    }
    
    var body: some View {
        if sortedCategories.isEmpty {
            Text("No categories found")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.leading)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                TagView(spacing: 4) {
                    ForEach(sortedCategories) { category in
                        CategoryLabel(category: category, selectedCategory: $selection)
                    }
                    Button {
                        showAddCategory.toggle()
                    } label: {
                        Label("New", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                }
                .frame(minHeight: 80)
            }
            .sheet(isPresented: $showAddCategory) {
                TransactionCategoryForm(
                    editor: TransactionCategoryEditor()
                ) { category in
                    self.selection = category
                }
                .tint(.accentColor)
            }
        }
    }
}

fileprivate struct PreviewView: View {
    @State var selection: TransactionCategory? = nil
    
    var body: some View {
        TransactionCategoryPicker(selection: $selection)
    }
}
