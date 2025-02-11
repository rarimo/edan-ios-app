import SwiftUI

enum HomeTabs: Int {
    case wallet
    case profile
}

struct HomeView: View {
    @State private var selectedTab: HomeTabs = .wallet

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                WalletView()
                    .tag(HomeTabs.wallet)
                ProfileView()
                    .tag(HomeTabs.profile)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            HomeTabsView(selectedTab: $selectedTab)
        }
    }
}

struct HomeTabsView: View {
    @Binding var selectedTab: HomeTabs

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 1000)
                    .foregroundStyle(.secondaryDark)
                    .frame(width: 108, height: 56)
                HStack(spacing: 0) {
                    tabButton(tab: .wallet, iconName: Icons.userWallet)
                    tabButton(tab: .profile, iconName: Icons.userProfile)
                }
            }
        }
    }

    func tabButton(tab: HomeTabs, iconName: String) -> some View {
        Button(action: { selectedTab = tab }) {
            ZStack {
                Circle()
                    .foregroundStyle(selectedTab == tab ? .primaryMain : .secondaryDark)
                Image(iconName)
                    .renderingMode(.template)
                    .foregroundStyle(selectedTab == tab ? .secondaryDark : .white)
            }
            .frame(width: 48, height: 48)
        }
    }
}

#Preview {
    let userManager = UserManager.shared

    userManager.userFace = UIImage(named: Images.man)

    return HomeView()
        .environmentObject(WalletManager.shared)
        .environmentObject(userManager)
        .environmentObject(AppView.ViewModel())
}
