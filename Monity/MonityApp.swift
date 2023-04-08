//
//  MonityApp.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

@main
struct MonityApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    @State private var tabSelection = 1
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @State private var showOverlay: Bool = false
    
    var body: some View {
        TabView(selection: $tabSelection) {
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "arrow.left.arrow.right")
                }
                .tag(0)
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
                .tag(2)
        }
        .onChange(of: scenePhase) { newPhase in
            withAnimation(.easeInOut) {
                showOverlay = newPhase != .active
            }
        }
        .overlay {
            if showOverlay {
                ZStack {
                    Rectangle().foregroundStyle(.regularMaterial).ignoresSafeArea()
                    VStack {
                        Group {
                            if colorScheme == .dark {
                                Image("IconImageDark").resizable()
                            } else {
                                Image("IconImageLight").resizable()
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
        }
    }
}
