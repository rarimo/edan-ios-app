import SwiftUI

struct WalletView: View {
    @EnvironmentObject private var walletManager: WalletManager

    @State private var isReceiveSheetShown = false
    @State private var isSendSheetShown = false

    var body: some View {
        wrapInGradient {
            VStack {
                header
                WarningView(text: "ZK Face technology is currently in beta, with balance limits in place")
                Spacer()
                balance
                    .padding(100)
                Spacer()
                ScrollView {
                    actions
                    assets
                }
            }
        }
        .sheet(isPresented: $isReceiveSheetShown, content: WalletReceiveView.init)
        .sheet(isPresented: $isSendSheetShown, content: WalletSendView.init)
    }

    func wrapInGradient(_ body: () -> some View) -> some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Gradients.primary)
                    .ignoresSafeArea()
                body()
            }
        }
    }

    var balance: some View {
        Button(action: walletManager.updateBalance) {
            Text("$\(walletManager.balanceString)")
                .h3()
                .foregroundStyle(.textPrimary)
        }
        .isLoading(walletManager.isBalanceLoading)
    }

    var header: some View {
        HStack {
            UserProfileIconView()
                .controlSize(.mini)
            Text("Unforgettable")
                .subtitle4()
                .foregroundStyle(.textPrimary)
                .padding(.leading)
        }
        .padding(.bottom)
        .padding(.leading, 30)
        .align()
    }

    var actions: some View {
        HStack {
            Button(action: { isReceiveSheetShown = true }) {
                action(name: "Receive", iconName: Icons.arrowDown)
            }
            Button(action: { isSendSheetShown = true }) {
                action(name: "Send", iconName: Icons.arrowUp)
            }
        }
    }

    func action(name: String, iconName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(.componentPrimary)
            VStack(spacing: 20) {
                Image(iconName)
                Text(name)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
            }
        }
        .frame(width: 177, height: 120)
    }

    var assets: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(.componentPrimary)
            VStack(alignment: .leading, spacing: 20) {
                Text("Assets")
                    .subtitle3()
                    .foregroundStyle(.textPrimary)
                HStack {
                    Image(walletManager.tokenName)
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text(walletManager.tokenName)
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                        .padding(.leading, 10)
                    Spacer()
                    Text("$\(walletManager.balanceString)")
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                }
            }
            .padding(.horizontal, 25)
        }
        .frame(width: 358, height: 120)
    }
}

#Preview {
    let walletManager = WalletManager.shared
    walletManager.accountAddress = "0x00000000000000000000000"

    let userManager = UserManager.shared
    userManager.userFace = UIImage(named: Images.man)

    return WalletView()
        .environmentObject(walletManager)
        .environmentObject(userManager)
        .environmentObject(AppView.ViewModel())
}
