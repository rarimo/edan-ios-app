import Foundation

extension AppView {
    class ViewModel: ObservableObject {
        @Published var isIntroFinished = AppUserDefaults.shared.isIntroFinished {
            didSet {
                AppUserDefaults.shared.isIntroFinished = isIntroFinished
            }
        }

        @Published var isPassportPresent = (try? AppKeychain.containsValue(.passportJson)) ?? false

        @Published var isFaceRecoveryEnabled = AppUserDefaults.shared.isFaceRecoveryEnabled {
            didSet {
                AppUserDefaults.shared.isFaceRecoveryEnabled = isFaceRecoveryEnabled
            }
        }

        func reset() {
            isIntroFinished = false
            isPassportPresent = false
            isFaceRecoveryEnabled = false
        }
    }
}
