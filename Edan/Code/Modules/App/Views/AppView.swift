import SwiftUI

struct AppView: View {
    @State private var isIntroFinished = AppUserDefaults.shared.isIntroFinished {
        didSet {
            AppUserDefaults.shared.isIntroFinished = isIntroFinished
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if isIntroFinished {
                MainView()
            } else {
                IntroView {
                    isIntroFinished = true
                }
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
