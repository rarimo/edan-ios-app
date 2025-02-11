import SwiftUI

struct CheatView: View {
    @EnvironmentObject private var walletManager: WalletManager

    @State private var isTokensMinting = false

    var body: some View {
        VStack {
            Text("Options")
                .foregroundStyle(.textPrimary)
                .h4()
            Spacer()
            AppButton(text: "Request tokens from the main wallet", action: mintTokens)
                .isLoading(isTokensMinting)
        }
        .padding()
        .presentationDetents([.fraction(0.25)])
    }

    func mintTokens() {
        isTokensMinting = true

        Task { @MainActor in
            defer {
                isTokensMinting = false
            }

            do {
                try await walletManager.mintERC20()

                walletManager.updateBalance()

                AlertManager.shared.emitSuccess("Tokens requested successfully")
            } catch {
                LoggerUtil.common.error("failed to mint ERC20: \(error.localizedDescription)")

                AlertManager.shared.emitError("Failed to request tokens")
            }
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: CheatView.init)
        .environmentObject(WalletManager.shared)
}
