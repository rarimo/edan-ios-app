import SwiftUI

struct SetupActionView: View {
    @StateObject var viewModel = BiometryViewModel()

    let action: SetupAction

    let onClose: () -> Void

    @State private var shouldShowCreateNewIntro = true

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
                        VStack {}
                    }
                case .restore:
                    VStack {}
                }
            }
        }
        .environmentObject(BiometryViewModel())
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

    var isFaceScanned: Bool {
        viewModel.loadingProgress >= 1
    }
}

#Preview {
    SetupActionView(action: .create) {}
}
