import Web3
import Web3ContractABI
import Web3PromiseKit

import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    let decimals: Int = 18

    let tokenName: String = "ETH"

    var balanceString: String {
        let balance = Double(balance) / pow(10, Double(decimals))

        return String(format: "%.3f", balance)
    }

    @Published var balance: BigUInt = 0

    @Published var isBalanceLoading: Bool = true

    @Published var accountAddress = ""

    @Published var isAccountAddressLoading: Bool = true

    init() {
        if !AppUserDefaults.shared.isIntroFinished {
            return
        }

        updateAccount()
    }

    func updateBalance() {
        isBalanceLoading = true

        Task { @MainActor in
            defer {
                isBalanceLoading = false
            }

            do {
                let ethereumAccountAddress = try EthereumAddress(hex: accountAddress, eip55: false)

                self.balance = try await retriveBalance(ethereumAccountAddress)
            } catch {
                LoggerUtil.common.error("failed to fetch balance: \(error.localizedDescription)")
            }
        }
    }

    func updateAccount() {
        isAccountAddressLoading = true

        Task { @MainActor in
            defer {
                isAccountAddressLoading = false
            }

            do {
                let ethereumAccountAddress = try await retriveAccountAddress()

                self.accountAddress = ethereumAccountAddress.hex(eip55: false)
                self.balance = try await self.retriveBalance(ethereumAccountAddress)
            } catch {
                LoggerUtil.common.error("failed to fetch account address: \(error.localizedDescription)")
            }
        }
    }

    func retriveBalance(_ address: EthereumAddress) async throws -> BigUInt {
        let web3 = Web3(rpcURL: ConfigManager.shared.general.evmRpcURL.absoluteString)

        let erc20Address = try EthereumAddress(hex: ConfigManager.shared.general.erc20Address, eip55: false)

        let erc20Contract = GenericERC20Contract(address: erc20Address, eth: web3.eth)

        let balanceOfResponse = try erc20Contract.balanceOf(address: address).call().wait()

        guard let balanceValue = balanceOfResponse["_balance"] as? BigUInt else {
            throw "Response does not contain balance"
        }

        return balanceValue
    }

    func retriveAccountAddress() async throws -> EthereumAddress {
        return try await AccountFactory.shared.getAccount(AccountManager.shared.featuresHash)
    }
}
