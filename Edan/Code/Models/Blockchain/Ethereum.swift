import Foundation

import Web3
import Web3ContractABI
import Web3PromiseKit

class Ethereum {
    static let ZERO_BYTES32: Data = .init(repeating: 0, count: 32)
    
    static let TX_PULL_INTERVAL: UInt64 = NSEC_PER_SEC * 3
    
    static let TX_SUCCESS_CODE: EthereumQuantity = 1
    
//    static let
    
    let web3: Web3
    
    init() {
        self.web3 = Web3(rpcURL: ConfigManager.shared.general.evmRpcURL.absoluteString)
    }
    
    func isTxSuccessful(_ txHash: String) async throws -> Bool? {
        let txHash = try EthereumData.string(txHash)
        
        var receipt: EthereumTransactionReceiptObject
        do {
            guard let responseReceipt = try web3.eth.getTransactionReceipt(transactionHash: txHash).wait() else {
                throw "Transaction receipt is nil"
            }
            
            receipt = responseReceipt
        } catch {
            if "\(error)".contains("emptyResponse") {
                return nil
            }
            
            throw "Failed to get transaction receipt: \(error)"
        }
        
        guard let status = receipt.status else {
            return nil
        }
        
        return status == Ethereum.TX_SUCCESS_CODE
    }
    
    func waitForTxSuccess(_ txHash: String) async throws {
        while true {
            let isTxSuccessfulResult = try await isTxSuccessful(txHash)
            
            if let isTxSuccessfulResult {
                if isTxSuccessfulResult {
                    break
                }
                
                throw "Transaction failed"
            }
            
            try await Task.sleep(nanoseconds: Ethereum.TX_PULL_INTERVAL)
        }
    }
    
    static func isValidAddress(_ address: String) -> Bool {
        guard address.hasPrefix("0x"), address.count == 42 else {
            return false
        }
        
        let validHexChars = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        let addressWithoutPrefix = address.dropFirst(2)
        return addressWithoutPrefix.unicodeScalars.allSatisfy { validHexChars.contains($0) }
    }
    
    static func toEthSignedMessage(_ message: Data) -> Data {
        let prefix = "\u{19}Ethereum Signed Message:\n\(message.count)".data(using: .utf8) ?? Data()
        
        return prefix + message
    }
}

struct EvmTxResponse: Codable {
    let data: EvmTxResponseData
    let included: [String]
}

struct EvmTxResponseData: Codable {
    let id, type: String
    let attributes: EvmTxResponseAttributes
}

struct EvmTxResponseAttributes: Codable {
    let txHash: String

    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
    }
}
