//
//  CurrentMonthOverviewTile.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import SwiftUI

struct CurrentMonthOverviewTile: View {
    @AppStorage("monthly_limit") private var monthlyLimit: Double = 0
    @State private var remainingAmount: Double = 0
    @StateObject private var content = MonthlyOverviewViewModel()
    
    var body: some View {
        DashboardBox {
            VStack(alignment: .leading) {
                HStack {
                    Text("Monthly Overview")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
                Text("Days left:")
                    .font(.system(size: 18, weight: .semibold))
                Text("\(content.remainingDays)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Budget:")
                    .font(.system(size: 18, weight: .semibold))
                Text(remainingAmount, format: .currency(code: "EUR"))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(remainingAmount >= 0 ? .green : .red)
                Spacer()
            }
            .padding()
        }
        .contextMenu { contextMenu } preview: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.secondary)
                Text("Preview")
            }
            .frame(maxWidth: .infinity)
            .frame(minWidth: 400, minHeight: 350)
        }
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        Button {
            // Add this item to a list of favorites.
        } label: {
            Label("Hide", systemImage: "eye.slash.fill")
        }
    }
}

struct CurrentMonthOverviewTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
