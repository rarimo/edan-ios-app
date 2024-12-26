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
    }
}

#Preview {
    AppView()
        .environmentObject(AlertManager.shared)
}
