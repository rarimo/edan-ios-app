import Foundation
import Identity

class CalldataBuilderManager {
    static let shared = CalldataBuilderManager()

    let accountFactory = AccountFactory()
    let biometryAccount = BiometryAccount()
}

extension CalldataBuilderManager {
    class AccountFactory {
        func deployAccount(_ zkProof: ZkProof) throws -> Data {
            let owner = AccountManager.shared.ethreumAddress

            return try IdentityCalldataBuilder().buildDeployAccountCalldata(owner, zkProofJSON: zkProof.json)
        }

        func deleteAccount(_ biometricHashDec: String) throws -> Data {
            return try IdentityCalldataBuilder().buildDeleteAccountCalldata(biometricHashDec)
        }
    }
}

extension CalldataBuilderManager {
    class BiometryAccount {
        func recover(_ zkProof: ZkProof) throws -> Data {
            let newOwner = AccountManager.shared.ethreumAddress

            return try IdentityCalldataBuilder().buildRecoverCalldata(newOwner, zkProofJSON: zkProof.json)
        }

        func transferERC20(
            _ tokenAddress: String,
            _ to: String,
            _ value: String,
            _ signature: Data?
        ) throws -> Data {
            return try IdentityCalldataBuilder().buildTransferERC20Calldata(tokenAddress, toRaw: to, valueRaw: value, signature: signature)
        }
    }
}
