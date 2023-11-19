//
//  GroupBoxStyles.swift
//  Monity
//
//  Created by Niklas Kuder on 29.10.22.
//

import SwiftUI

struct CustomGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            Spacer()
            HStack {
                Spacer(minLength: 0)
                configuration.content
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemGroupedBackground)))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 8))
    }
}
