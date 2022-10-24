//
//  SavingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct SavingsView: View {
    @ObservedObject private var content = SavingsViewModel()
    
    @ViewBuilder
    var scrollViewContent: some View {
        if content.categories.isEmpty {
            VStack {
                Text("No Savings categories defined.")
                Text("Go to Settings > Savings to define your categories.")
            }
            .foregroundColor(.secondary)
            .padding()
            .multilineTextAlignment(.center)
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(content.categories) { category in
                        GroupBox(label: Text(category.wrappedName).groupBoxLabelTextStyle()) {
                            Circle()
                                .frame(width: 20)
                                .foregroundColor(.red)
                        }
                        .groupBoxStyle(CustomGroupBox())
                        .frame(minHeight: 200)
                    }
                }
                .padding()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                scrollViewContent
            }
            .navigationTitle("Savings")
        }
    }
}

struct CustomGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            Spacer()
            HStack {
                Spacer()
                configuration.content
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemGroupedBackground)))
    }
}

struct WealthView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsView()
    }
}
