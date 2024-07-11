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
        let enumeratedViews = subviews.enumerated()
        let firstRow = enumeratedViews.filter {
            $0.offset % 2 == 0
        }
        let secondRow = enumeratedViews.filter {
            $0.offset % 2 == 1
        }
        let row1Width: CGFloat = vDSP.sum(firstRow.map {
            Double($0.element.sizeThatFits(proposal).width)
        })
        let row2Width: CGFloat = vDSP.sum(secondRow.map {
            Double($0.element.sizeThatFits(proposal).width)
        })
        let totalSubviews = subviews.count
        let totalWidth = (CGFloat(totalSubviews) * self.spacing) + max(row1Width, row2Width)
        return .init(width: totalWidth, height: proposal.height ?? 0)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let row1Y: CGFloat = 0
        let row2Y: CGFloat = subviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0
        var row1X: CGFloat = 0
        var row2X: CGFloat = 0
        var currentY: CGFloat = row1Y
        
        subviews.forEach { view in
            let viewSize = view.sizeThatFits(proposal)
            
            let x: CGFloat = currentY == row1Y ? row1X : row2X
            view.place(at: CGPoint(x: x, y: currentY), proposal: proposal)
            currentY = currentY == row1Y ? (row2Y + spacing) : row1Y
            if x == row1X {
                row1X += (viewSize.width + spacing)
            } else {
                row2X += (viewSize.width + spacing)
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
            withAnimation {
                if selectedCategory == category {
                    selectedCategory = nil
                } else {
                    selectedCategory = category
                }
            }
        } label: {
            Label {
                Text(category.wrappedName)
            } icon: {
                if let icon = category.iconName {
                    Image(systemName: icon)
                }
            }
        }
        .buttonStyle(for: isSelected)
    }
}

struct TransactionCategoryPicker: View {
    @FetchRequest(
        entity: TransactionCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)]
    ) private var allCategories: FetchedResults<TransactionCategory>
    @Binding var selection: TransactionCategory?
    
    var sortedCategories: [TransactionCategory] {
        return allCategories.sorted { c1, c2 in
            c1.recentTransactionsCount > c2.recentTransactionsCount
        }
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
                }
                .frame(minHeight: 80)
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

#Preview {
    AddTransactionView(editor: TransactionEditor())
        .environment(\.managedObjectContext, PersistenceController.previewContext)
}
