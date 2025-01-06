import Web3
import Web3ContractABI
import Web3PromiseKit

import Foundation

class BiometryAccount {
    let web3: Web3
    let contract: DynamicContract
    
    init(_ contractAccount: EthereumAddress) {
        self.web3 = Web3(rpcURL: ConfigManager.shared.general.evmRpcURL.absoluteString)
        
        self.contract = try! web3.eth.Contract(
            json: Contracts.biometricAccountABI,
            abiKey: nil,
            address: contractAccount
        )
    }
    
    func recoveryNonce() async throws -> BigUInt {
        let response = try contract["recoveryNonce"]!().call().wait()
        
        guard let nonce = response[""] as? BigUInt else {
            throw "Response does not contain nonce"
        }
        
        
        
        return nonce
    }
    
    func getTransferERC20SignHash(
        _ token: EthereumAddress,
        _ to: EthereumAddress,
        _ value: BigUInt
    ) async throws -> Data {
        let response = try contract["getTransferERC20SignHash"]!(token, to, value).call().wait()
        
        guard let signHash = response[""] as? Data else {
            throw "Response does not contain signHash"
        }

        return signHash
    }
}
