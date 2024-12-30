import SwiftUI

struct BiometryRegisterView: View {
    @StateObject private var viewModel = BiometryViewModel()

    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            BiometryFaceView(
                biometryProcess: .register,
                onRecovered: {
                    LoggerUtil.common.info("Access created successfully")

                    AlertManager.shared.emitSuccess("Access created successfully")

                    onNext()
                },
                onError: { error in
                    LoggerUtil.common.error("Failed to create by biometry: \(error.localizedDescription)")

                    AlertManager.shared.emitError("\(error.localizedDescription)")
                    
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
