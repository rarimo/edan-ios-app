import SwiftUI

@main
struct EdanApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(AlertManager.shared)
        }
    }
}