import SwiftUI

struct BiometryRecoveryView: View {
    @StateObject private var viewModel = BiometryViewModel()

    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            BiometryFaceView(
                biometryProcess: .recovery,
                onRecovered: {
                    LoggerUtil.common.info("Access restored successfully")

                    AlertManager.shared.emitSuccess("Access restored successfully")

                    onNext()
                },
                onError: { error in
                    LoggerUtil.common.error("Failed to recover by biometry: \(error)")

                    AlertManager.shared.emitError("\(error.localizedDescription)")
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
