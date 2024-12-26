import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    var body: some View {
        VStack {
            Text("Settings")
                .h4()
            Spacer()
            AppButton(variant: .destructive, text: "Delete the account", action: logout)
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
}

#Preview {
    SettingsView()
        .environmentObject(AppView.ViewModel())
}
