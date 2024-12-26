import SwiftUI

struct AppBackgroundContainer<Content: View, Header: View>: View {
    var content: Content
    var header: Header?

    init(@ViewBuilder content: () -> Content, header: (() -> Header)? = nil) {
        self.content = content()
        self.header = header?()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.primaryDarker
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 45)
                .ignoresSafeArea()
                .frame(
                    height: UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 6
                )
                .foregroundStyle(.backgroundPure)
            VStack {
                VStack {
                    header
                }
                .frame(height: UIScreen.main.bounds.height / 6)
                Spacer()
                content
                Spacer()
            }
        }
        .frame(
            height: UIScreen.main.bounds.size.height
        )
    }
}

extension AppBackgroundContainer where Header == EmptyView {
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = nil
    }
}

#Preview {
    AppBackgroundContainer(
        content: {
            Text("Hello world!")
        },
        header: {
            Text("Header")
        }
    )
}
