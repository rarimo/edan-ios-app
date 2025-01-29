import SwiftUI

struct AppView: View {
    @EnvironmentObject private var internetConnectionManager: InternetConnectionManager

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            if !internetConnectionManager.isInternetPresent {
                InternetConnectionRequiredView()
            } else if viewModel.isIntroFinished {
                VStack {}
            } else {
                SetupView {
                    viewModel.isIntroFinished = true
                }
            }
            AlertManagerView()
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AppView()
        .environmentObject(AlertManager.shared)
        .environmentObject(InternetConnectionManager.shared)
}
