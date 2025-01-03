import Foundation
import Identity

class Poseidon {
    static func hash(_ data: [Data]) throws -> Data {
        let poseidonHash = IdentityNewPoseidonHash()
        guard let poseidonHash else { throw "failed to create PoseidonHash" }
        
        for datum in data {
            poseidonHash.add(datum)
        }
        
        var error: NSError?
        let result = poseidonHash.hash(&error)
        if let error {
            throw error
        }
        
        guard let result else { throw "failed to create PoseidonHash" }
        
        return result
    }
}
