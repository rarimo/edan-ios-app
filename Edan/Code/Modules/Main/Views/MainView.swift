import SwiftUI

struct MainView: View {
    @State private var isSettingsUp: Bool = false

    var body: some View {
        AppBackgroundContainer(
            content: {
                VStack {
                    contentHeader
                        .align(.trailing)
                        .padding(25)
                    Spacer()
                }
            },
            header: header
        )
        .sheet(isPresented: $isSettingsUp, content: SettingsView.init)
    }

    func header() -> some View {
        VStack {
            Spacer()
            HStack {
                Image(Icons.edan)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 25, height: 25)
                Text("Edan")
                    .h5()
            }
            .foregroundStyle(.baseWhite)
            .padding(.bottom)
        }
    }

    var contentHeader: some View {
        Button(action: { isSettingsUp = true }) {
            Image(systemName: "gearshape")
        }
    }
}

#Preview {
    MainView()
}
