import KeychainAccess
import SwiftUI

enum AppKeychainItemKey: String {
    case privateKey, featuresHash, passportJson
}

class AppKeychain {
    private static let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "undefined.bundle")

    static func getValue(_ key: AppKeychainItemKey) throws -> Data? {
        try keychain.getData(key.rawValue)
    }

    static func setValue(_ key: AppKeychainItemKey, _ value: Data) throws {
        try keychain.set(value, key: key.rawValue)
    }

    static func containsValue(_ key: AppKeychainItemKey) throws -> Bool {
        try keychain.contains(key.rawValue)
    }

    static func removeValue(_ key: AppKeychainItemKey) throws {
        try keychain.remove(key.rawValue)
    }

    static func removeAll() throws {
        try keychain.removeAll()
    }
}
