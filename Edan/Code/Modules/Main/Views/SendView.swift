import SwiftUI
import Web3

struct SendView: View {
    @EnvironmentObject private var mainViewModel: MainView.ViewModel

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

        Task { @MainActor in
            defer { isSending = false }

            do {
                guard let (to, amountToSend) = try validateInput() else {
                    return
                }

                try await WalletManager.shared.transferERC20(to, amountToSend)

                mainViewModel.addNewHistoryEntry(
                    type: .sent,
                    amount: Double(amount) ?? 0
                )

                AlertManager.shared.emitSuccess("Transaction sent!")

                onSent()
            } catch {
                LoggerUtil.common.error("failed to send transaction: \(error.localizedDescription)")

                AlertManager.shared.emitError("Unknown error")
            }
        }
    }

    func validateInput() throws -> (EthereumAddress, BigUInt)? {
        var wereErrors = false

        if !Ethereum.isValidAddress(address) {
            address = ""
            addressError = "Invalid address"

            wereErrors = true
        }

        if Double(amount) == nil {
            amount = ""
            amountError = "Invalid amount"

            wereErrors = true
        }

        if wereErrors {
            return nil
        }

        let amountRaw = BigUInt(UInt((Double(amount) ?? 0) * pow(10, Double(WalletManager.shared.decimals))))

        if amountRaw > WalletManager.shared.balance {
            amount = ""
            amountError = "Insufficient balance"

            return nil
        }

        return try (
            EthereumAddress(hex: address, eip55: false),
            amountRaw
        )
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            SendView {}
                .environmentObject(MainView.ViewModel())
        }
}
