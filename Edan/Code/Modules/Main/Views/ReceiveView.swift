import SwiftUI

struct ReceiveView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Edan payable account")
                .h5()
            Text(WalletManager.shared.accountAddress)
                .h6()
                .multilineTextAlignment(.center)
                .frame(width: 270)
                .foregroundStyle(.primaryDark)
            QRCodeView(code: WalletManager.shared.accountAddress)
                .padding(.vertical, 30)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ReceiveView()
}
