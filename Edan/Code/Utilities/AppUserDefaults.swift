import Foundation
import SwiftUI

public class AppUserDefaults: ObservableObject {
    public static let shared = AppUserDefaults()

    @AppStorage("is_intro_finished")
    public var isIntroFinished = false

    @AppStorage("history_entries")
    public var historyEntries = Data()

    func reset() {
        isIntroFinished = false
        historyEntries = Data()
    }
}
