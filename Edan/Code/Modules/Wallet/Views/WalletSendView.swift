import SwiftUI
import Web3

struct WalletSendView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject private var walletManager: WalletManager

    @State private var address: String = ""
    @State private var addressError: String = ""

    @State private var amount = ""
    @State private var amountError: String = ""

    @State private var isSending: Bool = false
    @State private var isScanning = false

    var body: some View {
        VStack {
            header
            Divider()
                .padding(.vertical)
            AppTextField(
                text: $address,
                errorMessage: $addressError,
                label: "Aaddress",
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
                label: "Withdraw amount",
                placeholder: "0.00",
                keyboardType: .numbersAndPunctuation,
                action: {
                    Button(action: { amount = walletManager.balanceString }) {
                        Text("MAX")
                            .buttonMedium()
                            .foregroundStyle(.textSecondary)
                    }
                }
            )
            Spacer()
            Divider()
                .padding(.vertical)
            footer
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

    var header: some View {
        HStack {
            Text("Receive")
                .h6()
                .foregroundStyle(.textPrimary)
            Spacer()
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .resizable()
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 12.5, height: 12.5)
        }
    }

    var footer: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Receiver gets")
                    .body3()
                    .foregroundStyle(.textSecondary)
                receiverGets
            }
            .padding(.leading)
            Spacer()
            AppButton(text: "Send", action: send)
                .frame(width: 170)
                .isLoading(isSending)
        }
    }

    var receiverGets: some View {
        let amount = amount.isEmpty ? "0" : amount

        return Text("\(amount) \(walletManager.tokenName)")
            .subtitle3()
            .foregroundStyle(.textPrimary)
    }

    func send() {
        isSending = true

        Task { @MainActor in
            defer { isSending = false }

            do {
                guard let (to, amountToSend) = try validateInput() else {
                    return
                }

                try await walletManager.transferERC20(to, amountToSend)

//                mainViewModel.addNewHistoryEntry(
//                    type: .sent,
//                    amount: Double(amount) ?? 0
//                )

                AlertManager.shared.emitSuccess("Transaction sent!")

                presentationMode.wrappedValue.dismiss()
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
        .sheet(isPresented: .constant(true), content: WalletSendView.init)
        .environmentObject(WalletManager.shared)
}
