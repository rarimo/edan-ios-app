import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    let general = General()
}

extension ConfigManager {
    class General {
        let version: String

        let evmRpcURL: URL
        let orgsApi: URL
        let accountFactoryAddress: String

        init() {
            do {
                self.version = try readFromInfoPlist(key: "CFBundleShortVersionString")

                self.evmRpcURL = try readURLFromInfoPlist(key: "EVM_RPC_URL")
                self.orgsApi = try readURLFromInfoPlist(key: "ORGS_API")
                self.accountFactoryAddress = try readFromInfoPlist(key: "ACCOUNT_FACTORY_ADDRESS")
            } catch {
                fatalError("ConfigManager.General init error: \(error.localizedDescription)")
            }
        }
    }
}

private func readFromInfoPlist<T>(key: String) throws -> T {
    guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? T else {
        throw "Couldn't find \(key) in Info.plist"
    }

    if let value = value as? String {
        return normalizeInfoPlistString(value) as! T
    }

    return value
}

private func readURLFromInfoPlist(key: String) throws -> URL {
    let value: String = try readFromInfoPlist(key: key)

    guard let url = URL(string: value) else { throw "\(key) isn't URL" }

    return url
}

private func readURLDictionaryFromInfoPlist(key: String) throws -> [String: URL] {
    let value: [String: String] = try readFromInfoPlist(key: key)

    var result: [String: URL] = [:]
    for item in value {
        guard let url = URL(string: normalizeInfoPlistString(item.value)) else { throw "\(key) isn't URL" }

        result[item.key] = url
    }

    return result
}

private func normalizeInfoPlistString(_ value: String) -> String {
    return value.starts(with: "\"")
        ? String(value.dropFirst().dropLast())
        : value
}
