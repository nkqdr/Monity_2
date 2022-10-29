//
//  NavigationGroupBoxLabel.swift
//  Monity
//
//  Created by Niklas Kuder on 29.10.22.
//

import SwiftUI

struct NavigationGroupBoxLabel: View {
    var title: LocalizedStringKey
    
    var body: some View {
        HStack {
            Text(title).groupBoxLabelTextStyle(.secondary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
    }
}
