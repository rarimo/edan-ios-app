import SwiftUI

struct AppView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var internetConnectionManager: InternetConnectionManager

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            if !internetConnectionManager.isInternetPresent {
                InternetConnectionRequiredView()
            } else if viewModel.isIntroFinished {
                HomeView()
            } else {
                SetupView {
                    walletManager.updateAccount()

                    viewModel.isIntroFinished = true
                }
            }
            AlertManagerView()
        }
        .environmentObject(viewModel)
        .onAppear {
            LoggerUtil.common.info("App started")

            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

#Preview {
    AppView()
        .environmentObject(AlertManager.shared)
        .environmentObject(InternetConnectionManager.shared)
        .environmentObject(WalletManager.shared)
}
