import SwiftUI

struct AppView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            MainView()
            AlertManagerView()
        }
    }
}

#Preview {
    AppView()
}
