import NFCPassportReader
import SwiftUI

struct ReadPassportNFCView: View {
    @EnvironmentObject private var passportViewModel: PassportViewModel

    let onNext: (_ passport: Passport) -> Void
    let onBack: () -> Void

    @State private var useExtendedMode = false

    var body: some View {
        VStack {
            Text("NFC Reader")
                .h4()
                .align()
                .padding()
            Spacer()
            LottieView(animation: Animations.scanPassport)
                .frame(width: .infinity, height: 300)
            Text("Place your passport cover to the back of your phone")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .frame(width: 250)
            Spacer()
            AppButton(text: "Scan", action: scanPassport)
                .controlSize(.large)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                .background(.backgroundPure)
        }
    }

    func scanPassport() {
        NFCScanner.scanPassport(
            passportViewModel.mrzKey ?? "",
            Data(),
            useExtendedMode,
            onCompletion: { result in
                switch result {
                case .success(let passport):
                    self.onNext(passport)
                case .failure(let error):
                    LoggerUtil.common.error("failed to read passport data: \(error.localizedDescription, privacy: .public)")

                    onBack()
                }
            }
        )
    }
}

#Preview {
    ReadPassportNFCView(onNext: { _ in }, onBack: {})
}
