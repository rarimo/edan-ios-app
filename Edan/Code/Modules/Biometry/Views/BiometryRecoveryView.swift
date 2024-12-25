import SwiftUI

struct BiometryRecoveryView: View {
    @StateObject private var viewModel = ViewModel()

    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            BiometryRecoveryFaceView(
                onRecovered: {
                    LoggerUtil.common.info("Access restored successfully")
                    
                    AlertManager.shared.emitSuccess("Access restored successfully")

                    onNext()
                },
                onError: { error in
                    LoggerUtil.common.error("Failed to recover by biometry: \(error)")

                    AlertManager.shared.emitError("Failed to recover by biometry:")
                }
            )
        }
        .background(.backgroundPure)
        .environmentObject(viewModel)
        .onDisappear {
            viewModel.recoveryTask?.cancel()
        }
    }
}

#Preview {
    BiometryRecoveryView(onNext: {}, onBack: {})
}
