import Combine
import Identity
import SwiftUI
import Web3

class PassportViewModel: ObservableObject {
    @Published var mrzKey: String?
    @Published var passport: Passport?

    func setMrzKey(_ value: String) {
        mrzKey = value
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
    }
}
