//
//  ListBase.swift
//  Monity
//
//  Created by Niklas Kuder on 29.10.22.
//

import SwiftUI

struct ListBase<Content>: View where Content: View {
    var content: () -> Content
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            content()
        }
    }
}
