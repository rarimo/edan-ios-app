import SwiftUI

struct AddFaceRecoveryView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    @StateObject var viewModel = BiometryViewModel()

    @State private var isFaceScanned = false

    var body: some View {
        withCloseButton {
            VStack {
                if isFaceScanned {
                    SetupActionLoader<SetupRegisterTask>(onCompletion: completion)
                } else {
                    SetupFaceView { faceImage in
                        userManager.updateFaceImage(faceImage)

                        isFaceScanned = true
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
}
