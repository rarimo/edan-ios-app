import SwiftUI

struct MainView: View {
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
                    HistoryView()
                        .frame(height: 350)
                }
            },
            header: header
        )
        .environmentObject(viewModel)
        .sheet(isPresented: $isSettingsUp, content: SettingsView.init)
        .sheet(isPresented: $isReceiveUp, content: ReceiveView.init)
        .sheet(isPresented: $isSendUp) {
            SendView {}
        }
        .onAppear(perform: addPreviewData)
    }

    func header() -> some View {
        VStack {
            Spacer()
            HStack {
                Image(Icons.edan)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 25, height: 25)
                Text("Edan")
                    .h5()
            }
            .foregroundStyle(.baseWhite)
            .padding(.bottom)
        }
    }

    var contentHeader: some View {
        HStack {
            Image(systemName: "info.circle")
            Spacer()
            Button(action: { UIPasteboard.general.string = WalletManager.shared.accountAddress }) {
                Text("\(WalletManager.shared.accountAddress)")
                    .h6()
                    .frame(width: 150)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: { isSettingsUp = true }) {
                Image(systemName: "gearshape")
            }
        }
    }

    var balance: some View {
        HStack {
            Text(WalletManager.shared.balanceString)
                .h3()
            Text(WalletManager.shared.tokenName)
                .h6()
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
    }

    func addPreviewData() {
        if !PreviewUtils.isPreview {
            return
        }

        viewModel.addNewHistoryEntry(type: .sent, amount: 393136403635686092)
        viewModel.addNewHistoryEntry(type: .received, amount: 1000000000000000000)
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
                        .foregroundStyle(.primaryDarker)
                    Image(icon)
                        .renderingMode(.template)
                        .foregroundStyle(.baseWhite)
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
}
