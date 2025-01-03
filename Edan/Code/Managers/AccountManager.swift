import Foundation
import Identity
import Web3

class AccountManager {
    static let shared = AccountManager()

    var privateKey: Data

    init() {
        privateKey = (try? AppKeychain.getValue(.privateKey)) ?? Data()
    }

    func generateNewPrivateKey() throws {
        guard let privateKey = IdentityNewBJJSecretKey() else {
            throw "Failed to generate private key"
        }

        try? AppKeychain.setValue(.privateKey, privateKey)

        self.privateKey = privateKey
    }

    var ethreumAddress: String {
        return (try? EthereumPrivateKey(privateKey).address.hex(eip55: false)) ?? ""
    }
}
