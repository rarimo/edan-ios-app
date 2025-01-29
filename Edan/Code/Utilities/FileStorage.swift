import Foundation

enum FileStorageKeys: String {
    case userFace = "userFace.png"
}

class FileStorage {
    private static let storageFolder = try! FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
    ).appendingPathComponent("data", conformingTo: .folder)

    static func saveData(_ data: Data, key: FileStorageKeys) throws {
        let savePath = storageFolder.appendingPathComponent(key.rawValue)

        try data.write(to: savePath)
    }

    static func loadData(key: FileStorageKeys) throws -> Data {
        let savePath = storageFolder.appendingPathComponent(key.rawValue)

        return try Data(contentsOf: savePath)
    }

    static func exists(key: FileStorageKeys) -> Bool {
        let savePath = storageFolder.appendingPathComponent(key.rawValue)

        return FileManager.default.fileExists(atPath: savePath.path)
    }
}
