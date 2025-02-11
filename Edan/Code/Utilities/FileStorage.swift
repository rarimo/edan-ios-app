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

        if !FileManager.default.fileExists(atPath: storageFolder.path) {
            try FileManager.default.createDirectory(at: storageFolder, withIntermediateDirectories: true, attributes: nil)
        }

        if FileManager.default.fileExists(atPath: savePath.path) {
            FileManager.default.createFile(atPath: savePath.path, contents: nil, attributes: nil)
        }

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

    static func remove(key: FileStorageKeys) {
        let savePath = storageFolder.appendingPathComponent(key.rawValue)

        do {
            try FileManager.default.removeItem(at: savePath)
        } catch {
            print("Error removing file: \(error)")
        }
    }
}
