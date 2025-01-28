import SwiftUI

struct SetupFaceView: View {
    @State private var isFaceScanned: Bool = false

    @State private var currentFace: Image? = PreviewUtils.isPreview ? Image(Images.man) : nil

    var body: some View {
        VStack {
            Text("Scan your face")
                .h4()
                .align()
                .padding()
                .opacity(isFaceScanned ? 0 : 1)
            Spacer()
            VStack {}
        }
    }
}

#Preview {
    SetupFaceView()
}
