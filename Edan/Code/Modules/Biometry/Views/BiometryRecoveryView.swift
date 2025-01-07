import SwiftUI

struct BiometryRecoveryView: View {
    @StateObject private var viewModel = BiometryViewModel()

    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            BiometryFaceView(
                biometryProcess: .recovery,
                onComplete: {
                    LoggerUtil.common.info("Access restored successfully")

                    AlertManager.shared.emitSuccess("Access restored successfully")

                    onNext()
                },
                onError: { error in
                    LoggerUtil.common.error("Failed to recover by biometry: \(error.localizedDescription)")

                    AlertManager.shared.emitError("\(error.localizedDescription)")

                    viewModel.clearImages()

                    onBack()
                }
            )
        }
        .background(.backgroundPure)
        .environmentObject(viewModel)
        .onDisappear {
            viewModel.processingTask?.cancel()
        }
    }
}

#Preview {
    BiometryRecoveryView(onNext: {}, onBack: {})
}
