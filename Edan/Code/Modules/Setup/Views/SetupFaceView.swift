import SwiftUI

struct SetupFaceView: View {
    @State private var progress: Double = 0

    @State private var currentFace: Image? = PreviewUtils.isPreview ? Image(Images.man) : nil

    var body: some View {
        VStack {
            Text("Scan your face")
                .h4()
                .align()
                .padding()
                .opacity(isFaceScanned ? 0 : 1)
            Spacer()
            Group {
                if let face = currentFace {
                    SetupFaceOverlay(progress: progress, faceImage: face)
                }
            }
            .frame(width: 350, height: 350)
            additionalInfo
                .frame(height: 100)
            Spacer()
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
        progress >= 1
    }
}

#Preview {
    SetupFaceView()
}
