import SwiftUI

struct SetupActionView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager

    @StateObject var viewModel = BiometryViewModel()

    let action: SetupAction

    let onComplete: () -> Void
    let onClose: () -> Void

    @State private var isFaceScanned = false

    @State private var faceImage: UIImage? = nil

    @State private var isLoaderFinished = false

    var body: some View {
        withCloseButton {
            VStack {
                switch action {
                case .create:
                    SetupCreateNewIntroView(onComplete: onComplete, onError: handleCreateAccountError)
                        .onAppear(perform: runProcess)
                case .restore:
                    actionView
                }
            }
        }
        .environmentObject(BiometryViewModel())
        .onDisappear {
            viewModel.clearImages()
        }
    }

    var actionView: some View {
        Group {
            if isFaceScanned {
                switch action {
                case .create:
                    EmptyView()
                case .restore:
                    SetupActionLoader<SetupRecoveryTask>(onCompletion: completion)
                }
            } else {
                SetupFaceView { faceImage in
                    userManager.updateFaceImage(faceImage)

                    isFaceScanned = true
                }
            }
        }
        .padding(.top, 50)
    }

    func withCloseButton(_ body: () -> some View) -> some View {
        ZStack(alignment: .topLeading) {
            body()
            VStack {
                if !isFaceScanned {
                    Button(action: onClose) {
                        ZStack {
                            Circle()
                                .foregroundColor(.componentPrimary)
                            Image(systemName: "xmark")
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .frame(width: 40, height: 40)
                }
            }
            .padding()
        }
    }

    func handleCreateAccountError(_ error: Error) {
        LoggerUtil.common.error("failed to create account: \(error)")

        AlertManager.shared.emitError("Failed to create account, node is not available")

        onClose()
    }

    func runProcess() {
        Task { @MainActor in
            do {
                guard let faceImage else {
                    throw "No face image found"
                }

                try await viewModel.recoverByBiometry(faceImage)

                while !isLoaderFinished {
                    try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
                }

                userManager.updateFaceImage(faceImage)

                appViewModel.isFaceRecoveryEnabled = true

                AlertManager.shared.emitSuccess("New recovery method added sucessfully")

                onComplete()
            } catch {
                LoggerUtil.common.error("failed to add recovery method: \(error.localizedDescription)")

                AlertManager.shared.emitError(error.localizedDescription)

                onClose()
            }
        }
    }

    func completion() {
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)

            isLoaderFinished = true
        }
    }
}

#Preview {
    SetupActionView(action: .create, onComplete: {}, onClose: {})
        .environmentObject(UserManager.shared)
}
