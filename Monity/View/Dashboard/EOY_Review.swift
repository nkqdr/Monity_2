//
//  EOY_Review.swift
//  Monity
//
//  Created by Niklas Kuder on 26.12.23.
//

import SwiftUI

fileprivate struct EOY_DetailView: View {
    @StateObject private var content = EOYViewModel()
    var yearString: String
    
    var body: some View {
        ListBase {
            ScrollView(showsIndicators: false) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("You have registered a total of \(content.totalAmountOfTransactions) transactions this year.")
                        Text("\(content.totalAmountOfIncomeTransactions) of these transactions were registered as income and \(content.totalAmountOfExpenseTransactions) were registered as expenses.")
                    }
                }
            }
        }
        .navigationTitle("\(yearString) Review")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct EOY_ReviewTile: View {
    
    var body: some View {
        NavigationLink(destination: EOY_DetailView(yearString: Date().formatted(.dateTime.year()))) {
            VStack(alignment: .leading) {
                HStack {
                    Group {
                        Text("🎊") +
                        Text(Date(), format: .dateTime.year()) +
                        Text(" is coming to an end 🎊")
                    }
                    .font(.headline.bold())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .padding(.top, 4)
                }
                Text("Your Financial Year at a Glance")
            }
        }
        .foregroundStyle(.primary)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        EOY_ReviewTile()
    }
}
