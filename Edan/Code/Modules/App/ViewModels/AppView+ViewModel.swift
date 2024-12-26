import Foundation

extension AppView {
    class ViewModel: ObservableObject {
        @Published var isIntroFinished = AppUserDefaults.shared.isIntroFinished {
            didSet {
                AppUserDefaults.shared.isIntroFinished = isIntroFinished
            }
        }

        func reset() {
            isIntroFinished = false
        }
    }
}
