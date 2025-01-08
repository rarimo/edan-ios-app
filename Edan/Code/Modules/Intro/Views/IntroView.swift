import SwiftUI

enum AccountSetupRoute: Hashable {
    case passport, createNewAccount, recoverLostAccount
}

struct IntroView: View {
    @State private var path: [AccountSetupRoute] = []

    @State private var nextRoute: AccountSetupRoute = .createNewAccount

    var onFinishedIntro: () -> Void = {}

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: AccountSetupRoute.self) { route in
                switch route {
                case .passport:
                    ScanPassportView(
                        onComplete: { passport in
                            try? AppKeychain.setValue(.passportJson, passport.json)

                            path.append(nextRoute)
                            path.remove(at: 0)
                        },
                        onClose: {
                            _ = path.popLast()
                        }
                    )
                    .navigationBarHidden(true)
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
                    self.nextRoute = .createNewAccount

                    path.append(.createNewAccount)
                }
                AppButton(variant: .secondary, text: "Recover a lost account", rightIcon: Icons.arrowRight) {
                    self.nextRoute = .recoverLostAccount

                    path.append(.passport)
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
