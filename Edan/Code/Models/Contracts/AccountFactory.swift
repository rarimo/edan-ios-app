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
}
