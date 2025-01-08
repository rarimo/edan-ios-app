import SwiftUI

struct AppView: View {
    @EnvironmentObject private var internetConnectionManager: InternetConnectionManager

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            if !internetConnectionManager.isInternetPresent {
                InternetConnectionRequiredView()
            } else if !viewModel.isPassportPresent && viewModel.isIntroFinished {
                ScanPassportView(
                    onComplete: { passport in
                        try? AppKeychain.setValue(.passportJson, passport.json)

                        viewModel.isPassportPresent = true
                    },
                    onClose: {
                        viewModel.isPassportPresent = true
                    }
                )
            } else if viewModel.isIntroFinished {
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
        .environmentObject(InternetConnectionManager.shared)
}
