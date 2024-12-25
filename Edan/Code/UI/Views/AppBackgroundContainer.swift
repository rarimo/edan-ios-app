import SwiftUI

struct AppBackgroundContainer<Content: View>: View {
    var content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.primaryDarker
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 45)
                .ignoresSafeArea()
                .frame(
                    height: UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 5
                )
                .foregroundStyle(.backgroundPure)
            content()
        }
    }
}

#Preview {
    AppBackgroundContainer {
        VStack {}
    }
}
