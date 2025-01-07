import Alamofire
import SwiftUI

private enum ScanPassportState {
    case scanMRZ
    case readNFC
}

struct ScanPassportView: View {
    let onComplete: (_ passport: Passport) -> Void
    let onClose: () -> Void

    @State private var state: ScanPassportState = .scanMRZ

    @StateObject private var passportViewModel = PassportViewModel()

    var body: some View {
        switch state {
        case .scanMRZ:
            VStack(spacing: 8) {
                ScanPassportMRZView(
                    onNext: { mrzKey in
                        passportViewModel.setMrzKey(mrzKey)

                        withAnimation { state = .readNFC }
                    },
                    onClose: onClose
                )
            }
            .padding(.bottom, 20)
            .background(.backgroundPrimary)
            .transition(.backslide)
        case .readNFC:
            ReadPassportNFCView(
                onNext: { passport in
                    passportViewModel.setPassport(passport)

                    onComplete(passport)

                    LoggerUtil.common.info("Passport read successfully: \(passport.fullName)")
                },
                onBack: { withAnimation { state = .scanMRZ } },
                onClose: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        }
    }
}

#Preview {
    return ScanPassportView(
        onComplete: { _ in },
        onClose: {}
    )
}
