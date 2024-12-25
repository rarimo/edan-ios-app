import SwiftUI

struct AppView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            if AppUserDefaults.shared.isIntroFinished {
                MainView()
            } else {
                IntroView()
            }
            AlertManagerView()
        }
        .background(Color.backgroundPure)
    }
}

#Preview {
    AppView()
        .environmentObject(AlertManager.shared)
}
