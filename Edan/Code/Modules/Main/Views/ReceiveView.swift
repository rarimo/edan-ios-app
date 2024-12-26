import SwiftUI

struct ReceiveView: View {
    var body: some View {
        VStack {
            Text("Receive")
                .h5()
                .foregroundStyle(.baseBlack)
                .padding(.bottom, 10)
            Text(WalletManager.shared.accountAddress)
                .h6()
                .multilineTextAlignment(.center)
                .frame(width: 270)
                .foregroundStyle(.baseBlack)
            QRCodeView(code: WalletManager.shared.accountAddress)
                .padding(.vertical, 30)
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: ReceiveView.init)
}
