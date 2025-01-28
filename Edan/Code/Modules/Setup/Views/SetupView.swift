import SwiftUI

enum SetupAction {
    case create
    case restore
}

struct SetupView: View {
    @State private var chosenAction: SetupAction?

    var body: some View {
        content
            .sheet(isPresented: .init(get: { chosenAction != nil }, set: { _ in chosenAction = nil })) {
                SetupActionView(action: chosenAction!) {
                    chosenAction = nil
                }
            }
    }

    var content: some View {
        wrapInGradient {
            VStack(spacing: 35) {
                Spacer()
                Image(Images.setup)
                VStack(spacing: 0) {
                    Text("Unforgettable")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("Wallet")
                        .h3()
                        .foregroundStyle(Gradients.text)
                }
                Text("The first self-recovery crypto wallet based on ZK biometrics")
                    .body2()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
                    .frame(width: 278)
                Spacer()
                VStack {
                    AppButton(text: "Create a new one") { chosenAction = .create }
                    AppButton(variant: .secondary, text: "Regain access") { chosenAction = .restore }
                }
                .frame(width: 342)
            }
        }
    }

    func wrapInGradient(_ body: () -> some View) -> some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Gradients.primary)
                    .ignoresSafeArea()
                body()
            }
        }
    }

    func registerProcess(_ action: SetupAction) {
        chosenAction = action
    }
}

#Preview {
    SetupView()
}
