import Web3
import Web3ContractABI
import Web3PromiseKit

import Foundation

class AccountFactory {
    static let shared = AccountFactory()
    
    let web3: Web3
    let contract: DynamicContract
    
    init() {
        self.web3 = Web3(rpcURL: ConfigManager.shared.general.evmRpcURL.absoluteString)
        
        let contractAccount = try! EthereumAddress(hex: ConfigManager.shared.general.accountFactoryAddress, eip55: false)
        
        self.contract = try! web3.eth.Contract(
            json: Contracts.accountFactoryABI,
            abiKey: nil,
            address: contractAccount
        )
    }
    
    func getAccountByOwner(_ owner: EthereumAddress) async throws -> EthereumAddress {        
        let response = try contract["getAccountByOwner"]!(owner).call().wait()
        
        guard let account = response[""] as? EthereumAddress else {
            throw "Response does not contain root"
        }
        
        return account
    }
    
    func getAccountByBioHash(_ biometricHash: Data) async throws -> EthereumAddress {
        let response = try contract["getAccountByBioHash"]!(biometricHash).call().wait()
                
        guard let account = response[""] as? EthereumAddress else {
            throw "Response does not contain root"
        }
        
        return account
    }
    
    func getRecoveryNonce(_ address: EthereumAddress) async throws -> BigUInt {
        let response = try contract["getRecoveryNonce"]!(address).call().wait()
        
        guard let nonce = response[""] as? BigUInt else {
            throw "Response does not contain nonce"
        }
        
        return nonce
    }
}
