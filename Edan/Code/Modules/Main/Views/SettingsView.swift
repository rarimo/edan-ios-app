import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    var body: some View {
        VStack {
            Text("Settings")
                .h4()
            Spacer()
            AppButton(variant: .destructive, text: "Delete the account", action: delete)
            AppButton(variant: .secondary, text: "Logout", action: logout)
        }
        .padding()
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
            do {
                let features = try JSONDecoder().decode([Double].self, from: AppUserDefaults.shared.faceFeatures)

                _ = try await ZKBiometricsSvc.shared.deleteValue(feature: features)

                logout()
            } catch {
                LoggerUtil.common.error("failed to delete account: \(error.localizedDescription)")

                AlertManager.shared.emitError("Failed to delete account")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppView.ViewModel())
}
