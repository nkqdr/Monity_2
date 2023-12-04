//
//  RenderAndShareButton.swift
//  Monity
//
//  Created by Niklas Kuder on 19.11.23.
//

import SwiftUI

struct RenderAndShareButton<C>: View where C: View {
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    @State private var renderedImage = Image(systemName: "photo")
    var previewTitle: LocalizedStringKey
    var message: LocalizedStringKey? = nil
    var width: CGFloat = 400
    var height: CGFloat = 400
    var content: () -> C
    
    @ViewBuilder
    private var imageContent: some View {
        Group {
            content()
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemGroupedBackground)))
        .frame(width: width, height: height)
    }
    
    @MainActor
    private func renderImage(with scheme: ColorScheme) {
        let renderer = ImageRenderer(content: imageContent.environment(\.colorScheme, scheme))
        
        renderer.scale = displayScale
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
    
    var body: some View {
        ShareLink(
            item: renderedImage,
            message: message != nil ? Text(message!) : nil,
            preview: SharePreview(
                previewTitle,
                image: renderedImage
            )) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.bordered)
        .onAppear {
            renderImage(with: colorScheme)
        }
        .onChange(of: colorScheme) { newScheme in
            renderImage(with: newScheme)
        }
    }
}
