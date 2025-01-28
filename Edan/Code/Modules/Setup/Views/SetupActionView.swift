import SwiftUI

struct SetupActionView: View {
    let action: SetupAction

    @State private var shouldShowCreateNewIntro = true

    var body: some View {
        VStack {
            switch action {
            case .create:
                if shouldShowCreateNewIntro {
                    SetupCreateNewIntroView {
                        shouldShowCreateNewIntro = false
                    }
                } else {
                    VStack {}
                }
            case .restore:
                VStack {}
            }
        }
    }
}

#Preview {
    SetupActionView(action: .create)
}
