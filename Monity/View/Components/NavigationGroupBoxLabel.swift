//
//  NavigationGroupBoxLabel.swift
//  Monity
//
//  Created by Niklas Kuder on 29.10.22.
//

import SwiftUI

struct NavigationGroupBoxLabel: View {
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var labelStyle: GroupBoxLabelStyle = .secondary
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).groupBoxLabelTextStyle(labelStyle)
                if let subtitle {
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
    }
}
