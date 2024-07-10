//
//  MonityApp.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

@main
struct MonityApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.managedObjectContext)
        }
    }
}

struct PrivacyBlurView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
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

struct MainTabView: View {
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage(AppStorageKeys.onboardingDone) private var onboardingDone: Bool = false
    @State private var tabSelection = 1
    @State private var showOnboarding: Bool = false
    
    
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
        .onAppear {
            if (!onboardingDone) {
                showOnboarding = true
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase != .active {
                sceneDelegate.show()
            } else {
                sceneDelegate.hide()
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
                .interactiveDismissDisabled()
        }
    }
}
