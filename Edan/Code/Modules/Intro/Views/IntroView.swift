import SwiftUI

struct IntroView: View {
    var body: some View {
        AppBackgroundContainer {
            VStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(Icons.edan)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 250, height: 250)
                Text("Edan")
                    .h4()
                Spacer()
                Text("Account setup")
                    .subtitle3()
                AppButton(text: "Create a new account", rightIcon: Icons.arrowRight) {}
                AppButton(variant: .secondary, text: "Recover a lost account", rightIcon: Icons.arrowRight) {}
            }
            .padding()
        }
    }
}

#Preview {
    IntroView()
}
