import SwiftUI

struct SetupActionView: View {
    @EnvironmentObject private var userManager: UserManager

    @StateObject var viewModel = BiometryViewModel()

    let action: SetupAction

    let onComplete: () -> Void
    let onClose: () -> Void

    @State private var isFaceScanned = false

    var body: some View {
        withCloseButton {
            VStack {
                switch action {
                case .create:
                    SetupCreateNewIntroView(onComplete: onComplete, onError: handleCreateAccountError)
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

    func completion() {
        Task { @MainActor in
            switch action {
            case .create:
                LoggerUtil.common.info("Account created successfully")

                AlertManager.shared.emitSuccess("Account created successfully")
            case .restore:
                LoggerUtil.common.info("Account recovered successfully")

                AlertManager.shared.emitSuccess("Account recovered successfully")
            }

            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)

            onComplete()
        }
    }
}

#Preview {
    SetupActionView(action: .create, onComplete: {}, onClose: {})
        .environmentObject(UserManager.shared)
}
