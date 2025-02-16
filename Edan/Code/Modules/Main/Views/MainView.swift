import SwiftUI

struct MainView: View {
    @EnvironmentObject private var walletManager: WalletManager

    @StateObject var viewModel = MainView.ViewModel()

    @State private var isSettingsUp: Bool = false
    @State private var isReceiveUp: Bool = false
    @State private var isSendUp: Bool = false

    var body: some View {
        AppBackgroundContainer(
            content: {
                VStack {
                    contentHeader
                        .padding(20)
                    balance
                        .padding()
                    actionBar
                        .padding()
                    Spacer()
//                    HistoryView()
//                        .frame(height: 350)
                }
            },
            header: header
        )
        .sheet(isPresented: $isSettingsUp, content: SettingsView.init)
        .sheet(isPresented: $isReceiveUp, content: ReceiveView.init)
        .sheet(isPresented: $isSendUp) {
            SendView {
                isSendUp = false
            }
        }
        .onAppear(perform: addPreviewData)
        .environmentObject(viewModel)
    }

    func header() -> some View {
        VStack {
            Spacer()
            HStack {
                Image(Icons.edan)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.baseBlack)
                Text("Edan")
                    .h5()
                    .foregroundStyle(.baseBlack)
            }
            .foregroundStyle(.baseWhite)
            .padding(.bottom)
        }
    }

    var contentHeader: some View {
        HStack {
            Button(action: mintERC20) {
                Image(systemName: "info.circle")
            }
            Spacer()
            VStack {
                if walletManager.isAccountAddressLoading {
                    ProgressView()
                        .controlSize(.regular)
                } else {
                    Button(action: { UIPasteboard.general.string = walletManager.accountAddress }) {
                        Text("\(walletManager.accountAddress)")
                            .h6()
                            .frame(width: 150)
                            .lineLimit(1)
                    }
                }
            }
            .frame(height: 25)
            Spacer()
            Button(action: { isSettingsUp = true }) {
                Image(systemName: "gearshape")
            }
        }
    }

    var balance: some View {
        Button(action: {
            walletManager.updateBalance()
        }) {
            HStack {
                VStack {
                    if walletManager.isBalanceLoading {
                        ProgressView()
                            .controlSize(.regular)
                    } else {
                        Text(WalletManager.shared.balanceString)
                            .h3()
                    }
                }
                .frame(height: 30)
                Text(WalletManager.shared.tokenName)
                    .h6()
            }
        }
    }

    var actionBar: some View {
        HStack(spacing: 20) {
            ActionButton(
                action: { isReceiveUp = true },
                icon: Icons.arrowDown,
                text: "Receive"
            )
            ActionButton(
                action: { isSendUp = true },
                icon: Icons.arrowUp,
                text: "Send"
            )
        }
        .disabled(walletManager.isBalanceLoading)
        .disabled(walletManager.isAccountAddressLoading)
    }

    func addPreviewData() {
        if !PreviewUtils.isPreview {
            return
        }

        viewModel.addNewHistoryEntry(type: .sent, amount: 393136403635686092)
        viewModel.addNewHistoryEntry(type: .received, amount: 1000000000000000000)
    }

    func mintERC20() {
        Task { @MainActor in
            do {
                try await walletManager.mintERC20()

                walletManager.updateBalance()
            } catch {
                LoggerUtil.common.error("failed to mint ERC20: \(error.localizedDescription)")
            }
        }
    }
}

struct ActionButton: View {
    var action: () -> Void

    var icon: String

    var text: String

    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .foregroundStyle(.primaryMain)
                    Image(icon)
                        .renderingMode(.template)
                        .foregroundStyle(.baseBlack)
                }
                .frame(width: 50, height: 50)
                Text(text)
                    .body4()
            }
        }
    }
}

#Preview {
    return MainView()
        .environmentObject(WalletManager.shared)
}
