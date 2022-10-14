//
//  DashboardBox.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct DashboardBox<Content>: View where Content: View {
    var minHeight: CGFloat = 0
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .frame(minHeight: minHeight)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct PreviewDashboardBox<AContent, BContent>: View where AContent: View, BContent : View {
    var minHeight: CGFloat = 0
    var content: () -> AContent
    var previewContent: (() -> BContent)?
    
    init(@ViewBuilder content: @escaping () -> AContent) {
        self.content = content
    }
    
    init(@ViewBuilder content: @escaping () -> AContent, @ViewBuilder previewContent: @escaping () -> BContent) {
        self.content = content
        self.previewContent = previewContent
    }
    
    var body: some View {
        content()
            .frame(minHeight: minHeight)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            .contextMenu { contextMenu } preview: { if let c = previewContent {
                c()
            } }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        Button {
            // Do nothing because contextMenu closes automatically
        } label: {
            Label("Hide", systemImage: "eye.slash.fill")
        }
    }
}

struct DashboardBox_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
