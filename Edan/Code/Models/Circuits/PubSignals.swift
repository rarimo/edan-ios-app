struct FisherfacePubSignals {
    var raw: [String]
    
    init(_ raw: [String]) {
        self.raw = raw
    }
    
    enum SignalKey: Int, CaseIterable {
        case featuresHash = 0
        case compirasionsResult = 1
        case nonce = 2
    }
    
    func getSignal(_ key: SignalKey) throws -> BN {
        let value = raw[key.rawValue]
        
        return try BN(dec: value)
    }
    
    func getSignalRaw(_ key: SignalKey) -> String {
        return raw[key.rawValue]
    }
}
