import SwiftUI

struct SetupFaceView: View {
    @EnvironmentObject private var viewModel: BiometryViewModel

    @State private var currentFace: Image? = PreviewUtils.isPreview ? Image(Images.man) : nil

    let onComplete: (UIImage) -> Void

    var body: some View {
        VStack {
            Text("Scan your face")
                .h4()
                .align()
                .padding()
                .opacity(isFaceScanned ? 0 : 1)
            Spacer()
            Group {
                if let face = viewModel.currentFrame {
                    SetupFaceOverlay(
                        progress: viewModel.loadingProgress,
                        faceImage: Image(decorative: face, scale: 1)
                    )
                } else {
                    Circle()
                        .foregroundStyle(.componentPrimary)
                }
            }
            .frame(width: 350, height: 350)
            additionalInfo
                .frame(height: 100)
            Spacer()
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onChange(of: viewModel.loadingProgress) { progress in
            if progress >= 1 {
                Task {
                    try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)

                    guard let faceImage = viewModel.faceImage else {
                        LoggerUtil.common.fault("failed to get user face")

                        return
                    }

                    onComplete(faceImage)
                }
            }
        }
    }

    var additionalInfo: some View {
        VStack {
            if isFaceScanned {
                Text("Done!")
                    .h4()
                    .foregroundStyle(.textPrimary)
                Text("Just like that")
                    .body2()
                    .foregroundStyle(.textSecondary)
            } else {
                Text("Please look directly at the screen under good lighting conditions")
                    .body3()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
                    .frame(width: 308)
            }
        }
    }

    var isFaceScanned: Bool {
        viewModel.loadingProgress >= 1
    }
}

#Preview {
    SetupFaceView { _ in }
        .environmentObject(BiometryViewModel())
}
