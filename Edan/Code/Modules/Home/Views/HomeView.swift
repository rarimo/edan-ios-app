import SwiftUI

private enum HomeTabs: Int {
    case wallet
    case profile
}

struct HomeView: View {
    @State private var selectedTab: HomeTabs = .wallet

    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView()
                .tag(HomeTabs.wallet)
            VStack {}
                .tag(HomeTabs.profile)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}

#Preview {
    let userManager = UserManager.shared

    userManager.userFace = UIImage(named: Images.man)

    return HomeView()
        .environmentObject(WalletManager.shared)
        .environmentObject(userManager)
}
