import SwiftUI

struct WalletReceiveView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject private var walletManager: WalletManager

    var body: some View {
        VStack {
            header
                .padding(.vertical, 10)
            Divider()
            WarningView(text: "A $500 limit applies to the account. To increase it, add additional recovery methods in your profile")
                .padding(.top)
            QRCodeView(code: walletManager.accountAddress)
                .padding(.top)
            Spacer()
            Text("Address:")
                .subtitle4()
                .foregroundStyle(.textPrimary)
            HStack {
                Text(walletManager.accountAddress)
                    .body2()
                Button(action: { UIPasteboard.general.string = walletManager.accountAddress }) {
                    Image(Icons.copySimple)
                }
            }
        }
        .padding()
        .presentationDetents([.fraction(0.65)])
    }

    var header: some View {
        HStack {
            Text("Receive")
                .h6()
                .foregroundStyle(.textPrimary)
            Spacer()
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .resizable()
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 12.5, height: 12.5)
        }
    }
}

#Preview {
    let walletManager = WalletManager.shared
    walletManager.accountAddress = "0x00000000000000000000000"

    return VStack {}
        .sheet(isPresented: .constant(true), content: WalletReceiveView.init)
        .environmentObject(walletManager)
}
