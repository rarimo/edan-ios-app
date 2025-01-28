import SwiftUI

struct SetupFaceOverlay: View {
    let progress: Double
    let faceImage: Image

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(Color.componentPrimary, style: StrokeStyle(lineWidth: 10, dash: [2, 15]))
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(Color.primaryDark, style: StrokeStyle(lineWidth: 10, dash: [2, 15]))
            }
            .rotationEffect(.degrees(-90))
            Group {
                if isFinished {
                    ZStack {
                        Circle()
                            .foregroundStyle(.primaryMain)

                        Image(Images.checkmark)
                    }
                } else {
                    faceImage
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .clipped()
                        .scaleEffect(x: -1, y: 1)
                }
            }
            .frame(maxWidth: 325, maxHeight: 325)
        }
        .animation(.smooth, value: progress)
    }

    var isFinished: Bool {
        progress >= 1
    }
}

#Preview {
    SetupFaceOverlay(progress: 0.5, faceImage: Image(Images.man))
        .frame(width: 350, height: 350)
}
