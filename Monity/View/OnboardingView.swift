//
//  OnboardingView.swift
//  Monity
//
//  Created by Niklas Kuder on 23.09.23.
//

import SwiftUI

struct SplashScreenBox: View {
    var title: LocalizedStringKey?
    var content: LocalizedStringKey
    var emoji: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(emoji).font(.largeTitle)
            VStack(alignment: .leading) {
                if let title {
                    Text(title).font(.headline).bold()
                }
                Text(content).font(.callout).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.vertical, 5)
    }
}

fileprivate struct IntroPage: View {
    @Binding var displayedPage: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Welcome to Monity!")
                .font(.title)
                .bold()
            SplashScreenBox(title: "Introduction", content: "Track expenses, income, accounts, and investments – Watch your wealth soar with Monity!", emoji: "ℹ️")
            SplashScreenBox(title: "My promise", content: "Your data is yours to control. It is stored exclusively on your device or in your iCloud account. Your privacy is my priority.", emoji: "🔒")
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        displayedPage += 1
                    }
                } label: {
                    Label("Get started", systemImage: "chevron.right.2")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct TagView: Layout {
    var spacing: CGFloat = 10
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return .init(width: proposal.width ?? 0, height: proposal.height ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        
        subviews.forEach { view in
            let viewSize = view.sizeThatFits(proposal)
            if (origin.x + viewSize.width + spacing > maxWidth) {
                origin.y += (viewSize.height + spacing)
                origin.x = bounds.origin.x
                view.place(at: origin, proposal: proposal)
                origin.x += (viewSize.width + spacing)
            } else {
                view.place(at: origin, proposal: proposal)
                origin.x += (viewSize.width + spacing)
            }
        }
    }
}

fileprivate struct Tag: Identifiable {
    var id: UUID = UUID()
    var name: String
    var isSelected: Bool = false
}

fileprivate extension View {
    @ViewBuilder
    func buttonStyle(for isSelected: Bool) -> some View {
        if (isSelected) {
            buttonStyle(.borderedProminent)
        } else {
            buttonStyle(.bordered)
        }
    }
}

fileprivate struct TransactionCategoryPage: View {
    @Binding var displayedPage: Int
    @State private var selectedCategoryNames:  [Tag] = [
        "Rent", "Hobbies", "Work", "Gifts", "Free-time", "Clothes", "Groceries", "University", "Insurance"
    ].compactMap { Tag(name: $0) }
    
    private func handleCreateCategories() {
        let selectedCategories = selectedCategoryNames.filter({ $0.isSelected }).map { $0.name }
        if (selectedCategories.isEmpty) {
            return
        }
        let _ = TransactionCategoryStorage.main.addIfNotExisting(set: selectedCategories.map { $0.localized })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            ScrollView(showsIndicators: false) {
                SplashScreenBox(title: "Transaction categories", content: "Categorize transactions in Monity for a detailed expense and income analysis, helping you understand where your money flows.", emoji: "ℹ️")
                SplashScreenBox(content: "What are your most active categories for both income and expenses?", emoji: "❔")
                TagView(spacing: 4) {
                    ForEach($selectedCategoryNames) { $tag in
                        Toggle(LocalizedStringKey(tag.name), isOn: $tag.isSelected)
                            .toggleStyle(.button)
                            .buttonStyle(for: tag.isSelected)
                    }
                }
                .padding(8)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .frame(height: 200)
                Text("Select as many categories as you want. You can further customize them in the settings.").font(.footnote).foregroundColor(.secondary)
            }
            HStack {
                Button("Skip") {
                    withAnimation {
                        displayedPage += 1
                    }
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Save & Continue") {
                    handleCreateCategories()
                    withAnimation {
                        displayedPage += 1
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct MonthlyLimitPage: View {
    @State private var monthlyLimit: Double? = nil
    @Binding var displayedPage: Int
    @FocusState var isFocused : Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            ScrollView(showsIndicators: false) {
                SplashScreenBox(title: "Monthly budget", content: "Set a monthly budget to unlock valuable insights for better financial control.", emoji: "ℹ️")
                SplashScreenBox(content: "What is the maximum amount of money you would like to spend each month?", emoji: "❔")
                TextField("Monthly budget", value: $monthlyLimit, format: .customCurrency())
                    .focused($isFocused)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                    .keyboardType(.numbersAndPunctuation)
                Text("You can adjust your monthly budget anytime in the settings.").font(.footnote).foregroundColor(.secondary)
            }
            HStack {
                Button("Skip") {
                    let delayTime: Double = isFocused ? 0.65 : 0
                    isFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                        withAnimation {
                            displayedPage += 1
                        }
                    }
                   
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Save & Continue") {
                    UserDefaults.standard.set(monthlyLimit, forKey: AppStorageKeys.monthlyLimit)
                    let delayTime: Double = isFocused ? 0.65 : 0
                    isFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                        withAnimation {
                            displayedPage += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct SavingsCategoriesPage: View {
    @Binding var displayedPage: Int
    @State private var selectedCategoryNames:  [Tag] = [
        "Savings", "Checking", "Crypto", "Wallet", "Stock portfolio"
    ].compactMap { Tag(name: $0) }
    
    private func handleCreateCategories() {
        let selectedCategories = selectedCategoryNames.filter({ $0.isSelected }).map { $0.name }
        if (selectedCategories.isEmpty) {
            return
        }
        let _ = SavingsCategoryStorage.main.addIfNotExisting(set: selectedCategories.map { $0.localized })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            ScrollView(showsIndicators: false) {
                SplashScreenBox(title: "Savings categories", content: "Define savings categories for a deeper insight into your investments and bank accounts, ensuring precise tracking and better financial control.", emoji: "ℹ️")
                SplashScreenBox(content: "In which categories do you currently have funds saved or invested?", emoji: "❔")
                TagView(spacing: 4) {
                    ForEach($selectedCategoryNames) { $tag in
                        Toggle(LocalizedStringKey(tag.name), isOn: $tag.isSelected)
                            .toggleStyle(.button)
                            .buttonStyle(for: tag.isSelected)
                    }
                }
                .padding(8)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .frame(height: 150)
                Text("Select as many categories as you want. You can further customize them in the settings.").font(.footnote).foregroundColor(.secondary)
            }
            HStack {
                Button("Skip") {
                    withAnimation {
                        displayedPage += 1
                    }
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Save & Continue") {
                    handleCreateCategories()
                    withAnimation {
                        displayedPage += 1
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 60)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct FinalWelcomeScreen: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("All done!")
                .font(.title2)
                .bold()
            SplashScreenBox(title: "Take Control of Your Finances", content: "Monity puts you in charge of your financial journey. Take control today.", emoji: "✅")
            HStack {
                Spacer()
                Button {
                    UserDefaults.standard.set(true, forKey: AppStorageKeys.onboardingDone)
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Label("Let's start!", systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 20)
        
    }
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var displayedPage: Int = 0
    
    var body: some View {
        TabView(selection: $displayedPage) {
            IntroPage(displayedPage: $displayedPage)
                .tag(0)
            MonthlyLimitPage(displayedPage: $displayedPage)
                .tag(1)
            TransactionCategoryPage(displayedPage: $displayedPage)
                .tag(2)
            SavingsCategoriesPage(displayedPage: $displayedPage)
                .tag(3)
            FinalWelcomeScreen(isPresented: $isPresented)
                .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
        OnboardingView(isPresented: .constant(true)).preferredColorScheme(.dark)
    }
}
