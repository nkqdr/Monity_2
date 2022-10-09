//
//  DashboardBox.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct DashboardBox: View {
    var title: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.green.opacity(0.4))
            VStack {
                Text(title)
                    .padding()
            }
        }
        .frame(minHeight: 230)
        .frame(maxWidth: .infinity)
        .contextMenu { contextMenu } preview: { contextPreview }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        Button {
            // Add this item to a list of favorites.
        } label: {
            Label("Add to Favorites", systemImage: "heart")
        }
        Button {
            // Open Maps and center it on this item.
        } label: {
            Label("Show in Maps", systemImage: "mappin")
        }
    }
    
    private var contextPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.secondary)
            Text("Preview")
        }
        .frame(maxWidth: .infinity)
        .frame(minWidth: 400, minHeight: 350)
    }
}

struct DashboardBox_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
