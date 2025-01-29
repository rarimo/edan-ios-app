import SwiftUI

struct WalletView: View {
    var body: some View {
        wrapInGradient {
            VStack {
                WarningView(text: "ZK Face technology is currently in beta, with balance limits in place")
                Spacer()
                actions
            }
        }
    }

    func wrapInGradient(_ body: () -> some View) -> some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Gradients.primary)
                    .ignoresSafeArea()
                body()
            }
        }
    }

    var actions: some View {
        HStack {
            action(name: "Receive", iconName: Icons.arrowDown) {}
            action(name: "Send", iconName: Icons.arrowUp) {}
        }
    }

    func action(name: String, iconName: String, action: () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(.componentPrimary)
            VStack(spacing: 20) {
                Image(iconName)
                Text(name)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
            }
        }
        .frame(width: 177, height: 120)
    }
}

#Preview {
    WalletView()
}
