import SwiftUI

private enum IntroTab: Int {
    case first
    case second
}

struct SetupCreateNewIntroView: View {
    @State private var selectedTab: IntroTab = .first

    var onFinish: () -> Void

    var body: some View {
        VStack {
            Spacer()
            TabView(selection: $selectedTab) {
                firstIntroBody
                    .tag(IntroTab.first)
                secontIntroBody
                    .tag(IntroTab.second)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 450)
            tabIndicators
            Spacer()
            VStack(spacing: 32) {
                Divider()
                AppButton(text: "Create an unforgettable wallet", action: onFinish)
            }
            .frame(width: 342)
        }
    }

    var firstIntroBody: some View {
        VStack(spacing: 70) {
            Image(Images.setupFirstIntro)
            Text("No more seed\nphrases")
                .h4()
                .multilineTextAlignment(.center)
                .foregroundStyle(.textPrimary)
        }
    }

    var secontIntroBody: some View {
        VStack(spacing: 70) {
            Image(Images.setupSecondIntro)
            VStack {
                Text("It’s just You")
                    .h4()
                Text("+ ZK Face  for managing all")
                    .subtitle2()
            }
        }
    }

    var tabIndicators: some View {
        HStack {
            tabIndicator(selectedTab == .first)
            tabIndicator(selectedTab == .second)
        }
        .animation(.smooth, value: selectedTab)
    }

    func tabIndicator(_ isActive: Bool) -> some View {
        RoundedRectangle(cornerRadius: 25)
            .frame(width: isActive ? 16 : 8, height: 8)
            .foregroundStyle(isActive ? .primaryMain : .componentPrimary)
    }
}

#Preview {
    SetupCreateNewIntroView {}
}
