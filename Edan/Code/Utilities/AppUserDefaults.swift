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

    @AppStorage("face_features")
    public var faceFeatures = Data()

    @AppStorage("account_address")
    public var accountAddress = ""

    func reset() {
        isIntroFinished = false
        historyEntries = Data()
        faceFeatures = Data()
        accountAddress = ""
    }
}
