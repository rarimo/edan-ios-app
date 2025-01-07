import Foundation

struct ThemedAnimation {
    let light: String
    let dark: String

    init(light: String, dark: String) {
        self.light = light
        self.dark = dark
    }

    init(_ name: String) {
        self.light = name
        self.dark = name
    }
}

enum Animations {
    static let passport = ThemedAnimation("Passport")
    static let scanPassport = ThemedAnimation("ScanPassport")
}
