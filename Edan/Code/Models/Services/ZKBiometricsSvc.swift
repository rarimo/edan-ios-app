import Alamofire
import Foundation
import UIKit

class ZKBiometricsSvc {
    static let shared = ZKBiometricsSvc()

    let url: URL

    init() {
        url = ConfigManager.shared.general.orgsApi
    }

    func addValue2(_ feature: [Double], _ subfeatures: [Double]) async throws {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value2")

        let request = ZKBiometricsAddValue2Request(
            data: .init(
                id: "",
                type: "value",
                attributes: .init(
                    feature: feature,
                    subfeatures: subfeatures
                )
            )
        )

        _ = try await AF.request(
            requestURL,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
        .validate(OpenApiError.catchInstance)
        .serializingData()
        .result
        .get()
    }

    func getValue2(_ features: [[Double]]) async throws -> ZKBiometricsValue2Response? {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value2")

        let request = ZKBiometricsGetValueRequest(
            data: .init(
                id: "",
                type: "value",
                attributes: .init(
                    features: features
                )
            )
        )

        do {
            return try await AF.request(
                requestURL,
                method: .patch,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(ZKBiometricsValue2Response.self)
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

    func deleteValue2(key: String? = nil, feature: [Double]? = nil) async throws {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value2")

        if let key {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[key]", value: key)])
        }

        if let feature {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[feature]", value: String(feature.json.utf8.dropFirst().dropLast()))])
        }

        // returns empty body
        _ = try await AF.request(
            requestURL,
            method: .delete
        )
        .validate(OpenApiError.catchInstance)
        .serializingData()
        .result
        .get()
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

    func deleteValue(key: String? = nil, feature: [Double]? = nil) async throws {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        if let key {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[key]", value: key)])
        }

        if let feature {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[feature]", value: String(feature.json.utf8.dropFirst().dropLast()))])
        }

        // returns empty body
        _ = try await AF.request(
            requestURL,
            method: .delete
        )
        .validate(OpenApiError.catchInstance)
        .serializingData()
        .result
        .get()
    }

    func relay(
        _ calldata: Data,
        _ destination: String,
        _ noSend: Bool = false
    ) async throws -> ZKBiometricsRelayResponse {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/relay")

        let request = ZKBiometricsRelayRequest(
            data: .init(
                id: "",
                type: "txs",
                attributes: .init(
                    destination: destination,
                    noSend: noSend,
                    txData: calldata.fullHex
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
        .serializingDecodable(ZKBiometricsRelayResponse.self)
        .result
        .get()
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

struct ZKBiometricsAddValue2Request: Codable {
    let data: ZKBiometricsAddValue2RequestData
}

struct ZKBiometricsAddValue2RequestData: Codable {
    let id, type: String
    let attributes: ZKBiometricsAddValue2RequestAttributes
}

struct ZKBiometricsAddValue2RequestAttributes: Codable {
    let feature: [Double]
    let subfeatures: [Double]
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

struct ZKBiometricsValue2Response: Codable {
    let data: ZKBiometricsValue2ResponseData
}

struct ZKBiometricsValue2ResponseData: Codable {
    let id, type: String
    let attributes: ZKBiometricsValue2ResponseAttributes
}

struct ZKBiometricsValue2ResponseAttributes: Codable {
    let key: String
    let feature: [Double]
    let subfeatures: [Double]
    let closestFeatures: [Double]
}

struct ZKBiometricsRelayRequest: Codable {
    let data: ZKBiometricsRelayRequestData
}

struct ZKBiometricsRelayRequestData: Codable {
    let id, type: String
    let attributes: ZKBiometricsRelayRequestAttributes
}

struct ZKBiometricsRelayRequestAttributes: Codable {
    let destination: String
    let noSend: Bool
    let txData: String

    enum CodingKeys: String, CodingKey {
        case destination
        case noSend = "no_send"
        case txData = "tx_data"
    }
}

struct ZKBiometricsRelayResponse: Codable {
    let data: ZKBiometricsRelayResponseData
}

struct ZKBiometricsRelayResponseData: Codable {
    let id, type: String
    let attributes: ZKBiometricsRelayResponseAttributes
}

struct ZKBiometricsRelayResponseAttributes: Codable {
    let txHash: String

    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
    }
}
