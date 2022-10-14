//
//  DashboardBox.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct DashboardBox<Content>: View where Content: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .frame(height: 230)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct DashboardBox_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
