import SwiftUI

@main
struct EdanApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(AlertManager.shared)
                .environmentObject(WalletManager.shared)
                .environmentObject(InternetConnectionManager.shared)
                .environmentObject(UserManager.shared)
        }
    }
}
