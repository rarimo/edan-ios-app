import Web3
import Web3ContractABI
import Web3PromiseKit

import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    let ownerAddress = "0xa28FD19165438ee002Bf3CE7c4D74484d9f4f0B5"
    let accountAddress = "0x832eceB65fC4c4549cb12CF3dd6bA447915a6244"

    let decimals: Int = 18

    let tokenName: String = "ETH"

    var balanceString: String {
        let balance = Double(balance) / pow(10, Double(decimals))

        return String(format: "%.3f", balance)
    }

    @Published var balance: BigUInt = 0

    @Published var isBalanceLoading: Bool = true

    init() {
        updateBalance()
    }

    func updateBalance() {
        isBalanceLoading = true

        Task { @MainActor in
            defer {
                isBalanceLoading = false
            }

            do {
                let web3 = Web3(rpcURL: ConfigManager.shared.general.evmRpcURL.absoluteString)

                let erc20Address = try EthereumAddress(hex: ConfigManager.shared.general.erc20Address, eip55: false)

                let erc20Contract = GenericERC20Contract(address: erc20Address, eth: web3.eth)

                let accountAddress = try EthereumAddress(hex: AccountManager.shared.ethreumAddress, eip55: false)

                let balanceOfResponse = try erc20Contract.balanceOf(address: accountAddress).call().wait()

                guard let balanceValue = balanceOfResponse[""] as? BigUInt else {
                    LoggerUtil.common.error("failed to fetch balance")
                    return
                }

                self.balance = balanceValue
            } catch {
                LoggerUtil.common.error("failed to fetch balance: \(error.localizedDescription)")
            }
        }
    }
}
