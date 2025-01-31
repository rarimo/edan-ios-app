import SwiftUI

struct SetupActionView: View {
    @EnvironmentObject private var userManager: UserManager

    @StateObject var viewModel = BiometryViewModel()

    let action: SetupAction

    let onComplete: () -> Void
    let onClose: () -> Void

    @State private var shouldShowCreateNewIntro = true
    @State private var isFaceScanned = false

    var body: some View {
        withCloseButton {
            VStack {
                switch action {
                case .create:
                    if shouldShowCreateNewIntro {
                        SetupCreateNewIntroView {
                            shouldShowCreateNewIntro = false
                        }
                    } else {
                        actionView
                    }
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
                    SetupActionLoader<SetupRegisterTask>(onCompletion: completion)
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
            .padding()
        }
    }

    func completion() {
        Task { @MainActor in
            LoggerUtil.common.info("Account created successfully")

            AlertManager.shared.emitSuccess("Account created successfully")

            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)

            onComplete()
        }
    }
}

#Preview {
    SetupActionView(action: .create, onComplete: {}, onClose: {})
        .environmentObject(UserManager.shared)
}
