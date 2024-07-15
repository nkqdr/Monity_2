//
//  IconPicker.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import SwiftUI


fileprivate let favoriteIcons: [String] = [
    "cart.fill", "car.fill", "bus.fill", "bag.fill", "house.fill", "fuelpump.fill",
    "graduationcap.fill", "gym.bag.fill", "hammer.fill", "tag.fill", "shippingbox.fill",
    "book.fill", "rectangle.3.group.fill", "heart.fill", "shield.checkered",
    "ellipsis.circle.fill", "basket.fill", "creditcard.fill", "suitcase.fill",
    "lock.fill", "airplane", "carrot.fill", "birthday.cake.fill"
]

fileprivate struct IconSelectionView: View {
    var name: String
    var isActive: Bool = false
    
    var iconColor: Color {
        isActive ? .accentColor : .secondary
    }
    
    var body: some View {
        Image(systemName: name)
            .font(.system(size: 20))
            .frame(width: 50, height: 50)
            .tintedBackground(isActive ? .accentColor : .secondary, cornerRadius: 8, backgroundOpacity: isActive ? 0.25 : 0.1)
    }
}

fileprivate struct IconPickerDetail: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: String?
    @State private var filteredIcons: [String] = []
    @State private var searchText: String = ""
    
    private func select(_ name: String?) {
        Haptics.shared.play(.soft)
        withAnimation(.easeInOut(duration: 0.2)) {
            if selection == name {
                selection = nil
            } else {
                selection = name
            }
            dismiss()
        }
    }
    
    var body: some View {
        ScrollView {
            if searchText.isEmpty {
                HStack {
                    Text("Favorites")
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal)
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .frame(width: 50, height: 50)
                        .tintedBackground(.red, cornerRadius: 8, backgroundOpacity: 0.3)
                        .onTapGesture {
                            select(nil)
                        }
                    ForEach(favoriteIcons, id: \.self) { name in
                        IconSelectionView(
                            name: name,
                            isActive: name == selection
                        )
                        .onTapGesture {
                            select(name)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            
            HStack {
                Text("All")
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                ForEach(filteredIcons, id: \.self) { name in
                    IconSelectionView(
                        name: name,
                        isActive: name == selection
                    )
                    .onTapGesture {
                        select(name)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            self.filteredIcons = getAllSymbols()
        }
        .onChange(of: searchText) { newValue in
            DispatchQueue.global(qos: .userInteractive).async {
                if searchText.isEmpty {
                    self.filteredIcons = getAllSymbols()
                } else {
                    self.filteredIcons = getAllSymbols().filter {
                        $0.contains(newValue.lowercased())
                    }
                }
            }
        }
        .searchable(text: $searchText)
    }
    
    // Loads all symbols from the plist file
    private func getAllSymbols() -> [String] {
        let forbiddenStrings = [
            "icloud", 
            "digitalcrown",
            "pencil.tip",
            "person.badge.key",
            "person.2.badge.key",
            "shareplay",
            "shared.with.you",
            "accessibility",
            "voiceover",
            "swift",
            "message",
            "video.bubble",
            "translate",
            "teletype",
            "video",
            "deskview",
            "applescript",
            "homekit",
            "safari",
            "faceid",
            "airtag",
            "macpro",
            "xserve",
            "mac",
            "airport",
            "ipod",
            "iphone",
            "ipad",
            "visionpro",
            "opticid",
            "applepencil",
            "magicmouse",
            "applewatch",
            "airpod",
            "beats",
            "earpods",
            "homepod",
            "appletv",
            "magsafe",
            "airplay",
            "shazam",
            "apple",
            "arkit",
            "livephoto",
            "playstation",
            "xbox",
            "touchid",
            "bonjour"
        ]
        var allSymbols = [String]()
        if let bundle = Bundle(identifier: "com.apple.CoreGlyphs"),
            let resourcePath = bundle.path(forResource: "name_availability", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: resourcePath),
            let plistSymbols = plist["symbols"] as? [String: String]
        {

            // Get all symbol names
            allSymbols = Array(plistSymbols.keys)
        }
        let filteredSymbols = allSymbols.filter {
            !$0.contains(".circle")
        }.filter {
            $0.split(separator: ".").count < 3
        }.filter {
            for string in forbiddenStrings {
                if $0.contains(string) {
                    return false
                }
            }
            return true
        }
        print(filteredSymbols.count)
//        print(filledSymbols)
        return filteredSymbols
    }
}

struct IconPicker: View {
    @Binding var selection: String?
    var title: LocalizedStringKey
    
    var body: some View {
        NavigationLink {
            IconPickerDetail(selection: $selection)
                .navigationTitle(title)
        } label: {
            HStack {
                Text(title)
                Spacer()
                if let selection {
                    Image(systemName: selection)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
