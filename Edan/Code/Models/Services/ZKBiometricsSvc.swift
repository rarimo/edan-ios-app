import Alamofire
import Foundation
import UIKit

class ZKBiometricsSvc {
    static let shared = ZKBiometricsSvc()

    let url: URL

    init() {
        url = ConfigManager.shared.general.orgsApi
    }

    func addValue(_ feature: [Double]) async throws -> ZKBiometricsValueResponse {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        let request = ZKBiometricsAddValueRequest(
            data: .init(
                id: "",
                type: "value",
                attributes: .init(
                    feature: feature
                )
            )
        )

        return try await AF.request(
            requestURL,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(ZKBiometricsValueResponse.self)
        .result
        .get()
    }

    func getValue(_ features: [[Double]]) async throws -> ZKBiometricsValueResponse? {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        let request = ZKBiometricsGetValueRequest(
            data: .init(
                id: "",
                type: "value",
                attributes: .init(
                    features: features
                )
            )
        )

        UIPasteboard.general.string = request.json.utf8

        do {
            return try await AF.request(
                requestURL,
                method: .patch,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(ZKBiometricsValueResponse.self)
            .result
            .get()
        } catch {
            let openApiHttpCode = try error.retriveOpenApiHttpCode()

            if openApiHttpCode == HTTPStatusCode.notFound.rawValue {
                return nil
            }

            throw error
        }
    }

    func deleteValue(key: String? = nil, value: Data? = nil) async throws -> ZKBiometricsValueResponse? {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        if let key {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[key]", value: key)])
        }

        if let value {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[value]", value: value.hex)])
        }

        do {
            return try await AF.request(
                requestURL,
                method: .delete
            )
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(ZKBiometricsValueResponse.self)
            .result
            .get()
        } catch {
            let openApiHttpCode = try error.retriveOpenApiHttpCode()

            if openApiHttpCode == HTTPStatusCode.notFound.rawValue {
                return nil
            }

            throw error
        }
    }
}

struct ZKBiometricsAddValueRequest: Codable {
    let data: ZKBiometricsAddValueRequestData
}

struct ZKBiometricsAddValueRequestData: Codable {
    let id, type: String
    let attributes: ZKBiometricsAddValueRequestAttributes
}

struct ZKBiometricsAddValueRequestAttributes: Codable {
    let feature: [Double]
}

struct ZKBiometricsGetValueRequest: Codable {
    let data: ZKBiometricsGetValueRequestData
}

struct ZKBiometricsGetValueRequestData: Codable {
    let id, type: String
    let attributes: ZKBiometricsGetValueRequestAttributes
}

struct ZKBiometricsGetValueRequestAttributes: Codable {
    let features: [[Double]]
}

struct ZKBiometricsValueResponse: Codable {
    let data: ZKBiometricsValueResponseData
}

struct ZKBiometricsValueResponseData: Codable {
    let id, type: String
    let attributes: ZKBiometricsValueResponseAttributes
}

struct ZKBiometricsValueResponseAttributes: Codable {
    let key: String
    let feature: [Double]
}
