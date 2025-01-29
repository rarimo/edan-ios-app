import SwiftUI

class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var userFace: UIImage? {
        didSet {
            guard let userFace = userFace else {
                return
            }

            do {
                guard let faceImageData = userFace.pngData() else {
                    throw "failed to retrive user face"
                }

                try FileStorage.saveData(faceImageData, key: .userFace)
            } catch {
                LoggerUtil.common.error("Failed to save face image: \(error.localizedDescription)")
            }
        }
    }

    init() {
        do {
            let faceImagePndData = try FileStorage.loadData(key: .userFace)

            guard let userFace = UIImage(data: faceImagePndData) else {
                throw "Failed to deserialize face image"
            }

            self.userFace = userFace
        } catch {
            userFace = nil
        }
    }
}
