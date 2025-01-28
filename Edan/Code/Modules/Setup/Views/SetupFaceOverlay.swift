import SwiftUI

struct SetupFaceOverlay: View {
    let progress: Double

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(Color.componentPrimary, style: StrokeStyle(lineWidth: 10, dash: [1, 15]))
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(Color.primaryDark, style: StrokeStyle(lineWidth: 10, dash: [1, 15]))
            }
            .rotationEffect(.degrees(-90))
            if isFinished {
                ZStack {
                    Circle()
                        .foregroundStyle(.primaryMain)
                        .frame(width: 325, height: 325)
                    Image(Images.checkmark)
                }
            }
        }
        .animation(.smooth, value: progress)
        .frame(width: 350, height: 350)
    }

    var isFinished: Bool {
        progress >= 1
    }
}

#Preview {
    SetupFaceOverlay(progress: 0.5)
}
