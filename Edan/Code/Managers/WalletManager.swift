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
        isBalanceLoading = true

        Task { @MainActor in
            defer {
                isAccountAddressLoading = false
                isBalanceLoading = false
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

    func transferERC20(
        _ to: EthereumAddress,
        _ amount: BigUInt
    ) async throws {
        let token = try EthereumAddress(hex: ConfigManager.shared.general.erc20Address, eip55: false)

        let addressAccount = try EthereumAddress(hex: accountAddress, eip55: false)

        let biometryAccount = BiometryAccount(addressAccount)

        let signHash = try await biometryAccount.getTransferERC20SignHash(token, to, amount)

        let signedMessage = Ethereum.toEthSignedMessage(signHash)

        let signer = try EthereumPrivateKey(privateKey: [UInt8](AccountManager.shared.privateKey))

        let (v, r, s) = try signer.sign(message: [UInt8](signedMessage))

        let vRecoverable = v + 27
        let vBytes = withUnsafeBytes(of: vRecoverable.bigEndian) { Data($0) }

        var signature = Data()
        signature.append(contentsOf: r)
        signature.append(contentsOf: s)
        signature.append(vBytes.last ?? 27)

        let calldata = try CalldataBuilderManager.shared.biometryAccount.transferERC20(
            token.hex(eip55: false),
            to.hex(eip55: false),
            amount.description,
            signature
        )

        let response = try await ZKBiometricsSvc.shared.relay(
            calldata,
            addressAccount.hex(eip55: false)
        )

        LoggerUtil.common.info("Transfer ERC20 TX hash: \(response.data.attributes.txHash)")

        try await Ethereum().waitForTxSuccess(response.data.attributes.txHash)
    }

    func mintERC20() async throws {
        let mintCalldata = try CalldataBuilderManager.shared.mockErc20Account.mint(
            accountAddress,
            "1000000000000000000"
        )

        let response = try await ZKBiometricsSvc.shared.relay(
            mintCalldata,
            ConfigManager.shared.general.erc20Address
        )

        LoggerUtil.common.info("Mint TX hash: \(response.data.attributes.txHash)")

        try await Ethereum().waitForTxSuccess(response.data.attributes.txHash)
    }
}
