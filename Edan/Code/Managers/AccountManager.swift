import Foundation
import Identity
import Web3

class AccountManager {
    static let shared = AccountManager()

    var privateKey: Data
    var featuresHash: Data

    init() {
        if AppUserDefaults.shared.isFirstRun {
            try? AppKeychain.removeAll()

            AppUserDefaults.shared.isFirstRun = false
        }

        privateKey = (try? AppKeychain.getValue(.privateKey)) ?? Data()
        featuresHash = (try? AppKeychain.getValue(.featuresHash)) ?? Data()
    }

    func generateNewPrivateKey() throws {
        guard let privateKey = IdentityNewBJJSecretKey() else {
            throw "Failed to generate private key"
        }

        try? AppKeychain.setValue(.privateKey, privateKey)

        self.privateKey = privateKey
    }

    func saveFeaturesHash(_ featuresHash: Data) {
        try? AppKeychain.setValue(.featuresHash, featuresHash)

        self.featuresHash = featuresHash
    }

    var ethreumAddress: String {
        return (try? EthereumPrivateKey(privateKey).address.hex(eip55: false)) ?? ""
    }
}
