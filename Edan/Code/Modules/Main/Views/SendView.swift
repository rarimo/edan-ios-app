import SwiftUI

struct SendView: View {
    @State private var address: String = ""
    @State private var addressError: String = ""

    @State private var amount = ""
    @State private var amountError: String = ""

    @State private var isSending: Bool = false
    @State private var isScanning = false

    let onSent: () -> Void

    var body: some View {
        VStack {
            Text("Send")
                .h5()
                .foregroundStyle(.baseBlack)
                .padding(.bottom, 10)
            AppTextField(
                text: $address,
                errorMessage: $addressError,
                label: "Receiver's address",
                placeholder: "0x000...00",
                action: {
                    Button(action: { isScanning = true }) {
                        Image(Icons.qrCode)
                            .iconMedium()
                            .foregroundStyle(.textSecondary)
                    }
                }
            )
            AppTextField(
                text: $amount,
                errorMessage: $amountError,
                label: "Amount",
                placeholder: "0.00",
                keyboardType: .numbersAndPunctuation
            )
            Spacer()
            if isSending {
                ProgressView()
            } else {
                AppButton(text: "Send", rightIcon: Icons.arrowRight, action: send)
            }
        }
        .padding()
        .presentationDetents([.medium])
        .fullScreenCover(isPresented: $isScanning) {
            ScanQR(onBack: { isScanning = false }) { scanResult in
                isScanning = false

                var newAddress = scanResult
                if newAddress.starts(with: "ethereum:") {
                    newAddress = newAddress.replacingOccurrences(of: "ethereum:", with: "")
                }

                address = newAddress
            }
        }
    }

    func send() {
        isSending = true
        defer { isSending = false }

        validateInput()

        AlertManager.shared.emitSuccess("Transaction sent!")

        onSent()
    }

    func validateInput() {
        if !Ethereum.isValidAddress(address) {
            address = ""
            addressError = "Invalid address"
        }

        if Int(amount) == nil {
            amount = ""
            amountError = "Invalid amount"
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            SendView {}
        }
}
