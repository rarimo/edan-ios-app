import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

class QRUtils {
    static func generateQRCode(_ string: String) -> UIImage {
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        
        let data = string.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        
        let ciimage = filter.outputImage!
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        return UIImage(ciImage: scaledCIImage)
    }
}
