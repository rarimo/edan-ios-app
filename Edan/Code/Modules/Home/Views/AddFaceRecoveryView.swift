import SwiftUI

struct AddFaceRecoveryView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    @StateObject var viewModel = BiometryViewModel()

    @State private var faceImage: UIImage? = nil

    var body: some View {
        withCloseButton {
            VStack {
                if faceImage != nil {
                    SetupActionLoader<SetupRegisterTask>(onCompletion: completion)
                        .onAppear(perform: runProcess)
                } else {
                    SetupFaceView { scannedFaceImage in
                        faceImage = scannedFaceImage
                    }
                }
            }
            .padding(.top, 50)
        }
        .environmentObject(viewModel)
    }

    func withCloseButton(_ body: () -> some View) -> some View {
        ZStack(alignment: .topLeading) {
            body()
            VStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
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

    func runProcess() {
        Task { @MainActor in
            do {
                guard let faceImage else {
                    throw "No face image found"
                }

                try await viewModel.addFaceRecoveryMethod(faceImage, walletManager.accountAddress)

                userManager.updateFaceImage(faceImage)

                AlertManager.shared.emitSuccess("New recovery method added sucessfully")

                appViewModel.isFaceRecoveryEnabled = true

                presentationMode.wrappedValue.dismiss()
            } catch {
                LoggerUtil.common.error("failed to add recovery method: \(error.localizedDescription)")

                AlertManager.shared.emitError(error.localizedDescription)

                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    func completion() {
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)

            AlertManager.shared.emitSuccess("New recovery method added sucessfully")

            appViewModel.isFaceRecoveryEnabled = true

            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: AddFaceRecoveryView.init)
        .environmentObject(AppView.ViewModel())
        .environmentObject(UserManager.shared)
        .environmentObject(WalletManager.shared)
}
