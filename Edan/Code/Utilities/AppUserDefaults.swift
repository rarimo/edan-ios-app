import Foundation
import SwiftUI

public class AppUserDefaults: ObservableObject {
    public static let shared = AppUserDefaults()

    @AppStorage("is_intro_finished")
    public var isIntroFinished = false

    @AppStorage("history_entries")
    public var historyEntries = Data()

    @AppStorage("is_first_run")
    public var isFirstRun = true

    @AppStorage("account_address")
    public var accountAddress = ""

    @AppStorage("is_face_recovery_enabled")
    public var isFaceRecoveryEnabled = false

    @AppStorage("key_face_features_json")
    public var keyFaceFeaturesJson = Data()

    var keyFaceFeatures: [Double] {
        get {
            return (try? JSONDecoder().decode([Double].self, from: keyFaceFeaturesJson)) ?? []
        }

        set {
            keyFaceFeaturesJson = newValue.json
        }
    }

    func reset() {
        isIntroFinished = false
        historyEntries = Data()
        accountAddress = ""
        keyFaceFeaturesJson = Data()
    }
}
