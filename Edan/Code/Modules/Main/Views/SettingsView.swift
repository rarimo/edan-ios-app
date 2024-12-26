import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    var body: some View {
        VStack {
            Text("Settings")
                .h4()
            Spacer()
            AppButton(variant: .destructive, text: "Delete the account", action: deleteAccount)
        }
        .padding()
    }

    func deleteAccount() {
        do {
            appViewModel.reset()

            try AppKeychain.removeAll()
        } catch {
            LoggerUtil.common.error("Failed to delete the account: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppView.ViewModel())
}
