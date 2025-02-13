import SwiftUI

struct CheatView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    @EnvironmentObject private var walletManager: WalletManager

    @State private var isTokensMinting = false

    var body: some View {
        VStack {
            Text("Options")
                .foregroundStyle(.textPrimary)
                .h4()
            Spacer()
            AppButton(text: "Restart features", action: delete)
            AppButton(text: "Request tokens from the main wallet", action: mintTokens)
                .isLoading(isTokensMinting)
        }
        .padding()
        .presentationDetents([.fraction(0.25)])
    }

    func logout() {
        do {
            AppUserDefaults.shared.reset()

            appViewModel.reset()

            try AppKeychain.removeAll()
        } catch {
            LoggerUtil.common.error("Failed to logout: \(error.localizedDescription)")
        }
    }

    func delete() {
        Task { @MainActor in
            guard let features = try? JSONDecoder().decode([Double].self, from: AppUserDefaults.shared.faceFeatures) else {
                logout()

                return
            }

            try? await ZKBiometricsSvc.shared.deleteValue(feature: features)

            logout()
        }
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
        .environmentObject(AppView.ViewModel())
}
