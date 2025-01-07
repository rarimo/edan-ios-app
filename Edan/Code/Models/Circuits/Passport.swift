import Foundation
import UIKit

import NFCPassportReader

struct Passport: Codable {
    var firstName: String
    var lastName: String
    var gender: String
    var passportImageRaw: String?
    var documentType: String
    var issuingAuthority: String
    var documentNumber: String
    var documentExpiryDate: String
    var dateOfBirth: String
    var nationality: String
    let dg1: Data
    let dg15: Data
    let sod: Data
    let signature: Data

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var passportImage: UIImage? {
        guard let passportImageRaw = passportImageRaw else {
            return nil
        }

        if let data = Data(base64Encoded: passportImageRaw, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        } else {
            return nil
        }
    }

    static func fromNFCPassportModel(_ model: NFCPassportModel) -> Passport? {
        let dg1 = model.getDataGroup(.DG1)?.data ?? []
        let dg15 = model.getDataGroup(.DG15)?.data ?? []
        let sod = model.getDataGroup(.SOD)?.data ?? []

        return Passport(
            firstName: model.firstName,
            lastName: model.lastName,
            gender: model.gender,
            passportImageRaw: model.passportImage?
                .pngData()?
                .base64EncodedString(options: .endLineWithLineFeed),
            documentType: model.documentType,
            issuingAuthority: model.issuingAuthority,
            documentNumber: model.documentNumber,
            documentExpiryDate: model.documentExpiryDate,
            dateOfBirth: model.dateOfBirth,
            nationality: model.nationality,
            dg1: Data(dg1),
            dg15: Data(dg15),
            sod: Data(sod),
            signature: Data(model.activeAuthenticationSignature)
        )
    }
}
