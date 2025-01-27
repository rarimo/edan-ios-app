import SwiftUI

class Gradients {
    static let primary = Gradient(colors: [.white, .primaryLighter])
    static let text = Gradient(stops: [.init(color: .textPrimary, location: 0.5), .init(color: .primaryDark, location: 1)])
}
