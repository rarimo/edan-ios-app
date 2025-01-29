import SwiftUI

struct SetupActionView: View {
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
                VStack {}
            } else {
                SetupFaceView {
                    do {
                        guard
                            let faceImage = viewModel.faceImage,
                            let faceImagePngData = faceImage.pngData()
                        else {
                            throw "Failed to serialize face image"
                        }

                        try FileStorage.saveData(faceImagePngData, key: .userFace)
                    } catch {
                        LoggerUtil.common.error("failed to save face image: \(error.localizedDescription)")

                        AlertManager.shared.emitError("Failed to save face image")

                        onClose()

                        return
                    }

                    onComplete()

                    // isFaceScanned = true
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
}

#Preview {
    SetupActionView(action: .create, onComplete: {}, onClose: {})
}
