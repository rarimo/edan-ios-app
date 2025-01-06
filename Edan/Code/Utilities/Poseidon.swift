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
    
    static func hashInt(_ numbers: [Int]) throws -> Data {
        let poseidonHash = IdentityNewPoseidonHash()
        guard let poseidonHash else { throw "failed to create PoseidonHash" }
        
        for number in numbers {
            poseidonHash.add(Int64(number))
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
