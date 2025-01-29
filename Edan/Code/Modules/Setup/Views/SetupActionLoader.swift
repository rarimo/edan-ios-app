import SwiftUI

struct SetupActionLoader<Process: SetupActionProgress>: View {
    var setupActionProgress: Process

    @State private var progress: Double = 0

    var body: some View {
        VStack {
            Text("Restoring access")
                .h4()
                .align()
                .padding()
            Spacer()
        }
    }
}

#Preview {
    SetupActionLoader(setupActionProgress: SetupRegisterProgress.creatingAccount)
}
