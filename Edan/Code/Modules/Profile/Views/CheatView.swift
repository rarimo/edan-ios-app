import SwiftUI

struct CheatView: View {
    @EnvironmentObject private var walletManager: WalletManager

    var body: some View {
        VStack {
            Text("Options")
                .foregroundStyle(.textPrimary)
                .h4()
            Spacer()
            AppButton(text: "Request tokens from the main wallet", action: mintTokens)
        }
        .padding()
    }

    func mintTokens() {
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

#Preview {
    CheatView()
        .environmentObject(WalletManager.shared)
}
