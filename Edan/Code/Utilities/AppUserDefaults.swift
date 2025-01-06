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

    func reset() {
        isIntroFinished = false
        historyEntries = Data()
    }
}
