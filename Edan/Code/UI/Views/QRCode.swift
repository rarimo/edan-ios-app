import QRCode
import SwiftUI

struct QRCodeView: View {
    let code: String
    let size: CGFloat = 160

    var qrImage: UIImage? {
        let doc = QRCode.Document(utf8String: code)

        let cgImage = doc.cgImage(CGSize(width: 400, height: 400))
        return cgImage == nil ? nil : UIImage(cgImage: cgImage!)
    }

    var body: some View {
        ZStack {
            ZStack {
                if let qrImage {
                    Image(uiImage: qrImage).square(size)
                } else {
                    Image(Icons.qrCode)
                        .square(size)
                        .foregroundColor(.errorMain)
                }
            }
            .padding(14)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.textPrimary, lineWidth: 7)
            )
        }
        .padding(4)
    }
}

#Preview {
    QRCodeView(code: WalletManager.shared.accountAddress)
}
