import Foundation

class WalletManager {
    static let shared = WalletManager()

    let ownerAddress = "0xa28FD19165438ee002Bf3CE7c4D74484d9f4f0B5"
    let accountAddress = "0x832eceB65fC4c4549cb12CF3dd6bA447915a6244"

    let balance: Int = 606863596364313908

    let decimals: Int = 18

    let tokenName: String = "ETH"

    var balanceString: String {
        let balance = Double(self.balance) / pow(10, Double(decimals))
        return String(format: "%.2f", balance)
    }

    init() {}
}
