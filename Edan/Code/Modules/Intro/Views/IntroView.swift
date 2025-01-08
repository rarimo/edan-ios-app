import SwiftUI

enum AccountSetupRoute: Hashable {
    case createNewAccount, recoverLostAccount
}

struct IntroView: View {
    @State private var path: [AccountSetupRoute] = []

    var onFinishedIntro: () -> Void = {}

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: AccountSetupRoute.self) { route in
                switch route {
                case .createNewAccount:
                    BiometryRegisterView(
                        onNext: onFinishedIntro,
                        onBack: {
                            path.removeAll()
                        }
                    )
                    .navigationBarHidden(true)
                case .recoverLostAccount:
                    BiometryRecoveryView(
                        onNext: onFinishedIntro,
                        onBack: {
                            path.removeAll()
                        }
                    )
                    .navigationBarHidden(true)
                }
            }
        }
    }

    var content: some View {
        AppBackgroundContainer {
            VStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(Icons.edan)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 250, height: 250)
                Text("Edan")
                    .h4()
                Spacer()
                Text("Account setup")
                    .subtitle3()
                AppButton(text: "Create a new account", rightIcon: Icons.arrowRight) {
                    path.append(.createNewAccount)
                }
                AppButton(variant: .secondary, text: "Recover a lost account", rightIcon: Icons.arrowRight) {
                    path.append(.recoverLostAccount)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }
}

#Preview {
    IntroView {}
}
