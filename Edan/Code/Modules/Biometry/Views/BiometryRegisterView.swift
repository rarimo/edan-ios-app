import SwiftUI

struct BiometryRegisterView: View {
    @StateObject private var viewModel = BiometryViewModel()

    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            BiometryFaceView(
                biometryProcess: .register,
                onComplete: {
                    LoggerUtil.common.info("Account created successfully")

                    AlertManager.shared.emitSuccess("Account created successfully")

                    onNext()
                },
                onError: { error in
                    LoggerUtil.common.error("Failed to create by biometry: \(error.localizedDescription)")

                    viewModel.clearImages()

                    AlertManager.shared.emitError("\(error.localizedDescription)")
                    onBack()
                }
            )
        }
        .background(.backgroundPure)
        .environmentObject(viewModel)
        .onDisappear {
            viewModel.clearImages()

            viewModel.processingTask?.cancel()
        }
    }
}

#Preview {
    BiometryRecoveryView(onNext: {}, onBack: {})
}
