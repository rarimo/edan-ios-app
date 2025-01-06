import SwiftUI

struct AppView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.isIntroFinished {
                MainView()
            } else {
                IntroView {
                    viewModel.isIntroFinished = true
                }
            }
            AlertManagerView()
        }
        .background(Color.backgroundPure)
        .environmentObject(viewModel)
        .onAppear {
            LoggerUtil.common.info("App started")
        }
    }
}

#Preview {
    AppView()
        .environmentObject(AlertManager.shared)
}
