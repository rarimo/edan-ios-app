import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    @EnvironmentObject private var walletManager: WalletManager

    @State private var isAddDocumentSheetPresented = false
    @State private var isAddFaceSheetPresented = false

    var body: some View {
        VStack {
            Text("Account")
                .subtitle3()
                .align()
            VStack(spacing: 30) {
                UserProfileIconView()
                VStack {
                    Text("Unforgettable")
                        .subtitle2()
                        .foregroundStyle(.textPrimary)
                    Button(action: { UIPasteboard.general.string = walletManager.accountAddress }) {
                        Text(walletManager.accountAddress)
                            .body3()
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
            .padding(.top, 50)
            info
                .padding(.top, 30)
                .padding(.bottom, 10)
            ScrollView {
                recoveryFeatures
            }
            Spacer()
            VStack {
                Divider()
                deleteAccountButton
                    .padding(.vertical)
                    .padding(.bottom, 50)
            }
        }
        .padding()
        .sheet(isPresented: $isAddDocumentSheetPresented, content: AddPassportRecoveryView.init)
        .sheet(isPresented: $isAddFaceSheetPresented, content: AddFaceRecoveryView.init)
    }

    var info: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.componentPrimary)
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(.warningLighter)
            VStack {
                Text("Biometric self-recovery")
                    .subtitle5()
                    .foregroundStyle(.warningMain)
                    .align()
                Text("Enable all recovery features for maximum protection")
                    .body3()
                    .foregroundStyle(.textPrimary)
                    .align()
            }
            .padding(.horizontal, 20)
        }
        .frame(width: 358, height: 100)
    }

    var recoveryFeatures: some View {
        VStack {
            ProfileRecoveryFeatureView(
                state: appViewModel.isFaceRecoveryEnabled ? .completed : .interactive,
                iconName: Icons.bodyScanLine, text: "ZK Face"
            ) {
                isAddFaceSheetPresented = true
            }
            ProfileRecoveryFeatureView(
                state: appViewModel.isPassportPresent ? .completed : .interactive,
                iconName: Icons.passportLine, text: "Passport or ID"
            ) {
                isAddDocumentSheetPresented = true
            }
            ProfileRecoveryFeatureView(state: .unavailable, iconName: Icons.accounPin, text: "Geolocation") {}
        }
    }

    var deleteAccountButton: some View {
        Button(action: logout) {
            Text("Delete the account")
                .subtitle3()
                .foregroundStyle(.errorDark)
        }
    }

    func logout() {
        do {
            AppUserDefaults.shared.reset()

            appViewModel.reset()

            try AppKeychain.removeAll()
        } catch {
            LoggerUtil.common.error("Failed to logout: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let walletManager = WalletManager.shared
    walletManager.accountAddress = "0x00000000000000000000000"

    let userManager = UserManager.shared
    userManager.userFace = UIImage(named: Images.man)

    return ProfileView()
        .environmentObject(walletManager)
        .environmentObject(userManager)
        .environmentObject(AppView.ViewModel())
}
