import Alamofire
import Foundation

class ZKBiometricsSvc {
    static let shared = ZKBiometricsSvc()

    let url: URL

    init() {
        url = ConfigManager.shared.general.orgsApi
    }

    func addValue(_ value: Data) async throws -> ZKBiometricsValueResponse {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        let request = ZKBiometricsAddValueRequest(
            data: .init(
                id: "",
                type: "value",
                attributes: .init(
                    value: value.base64EncodedString()
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

//    Delete value from storage. If no filter query specified nothing is delete, because one of filters is required.
//    When filtering by value, service queries by exact match and if any value found deletes it.
//    Also take into account that value is Base64 encoded, so may contain some escape symbol that should be encoded.
//
//    query Parameters
//    filter[key]
//    string
//    Example: filter[key]=550e8400-e29b-41d4-a716-446655440000
//    Param to filter values by uuid key
//
//    filter[value]
//    string
//    Example: filter[value]=aGVsbG8gd29ybGQ=
//    Param to filter data by Base64 encoded value
//

    func getValue(_ key: String? = nil, _ value: Data? = nil) async throws -> ZKBiometricsValueResponse {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        if key != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[key]", value: key)])
        }

        if value != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[value]", value: value?.base64EncodedString())])
        }

        return try await AF.request(
            requestURL,
            method: .get
        )
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(ZKBiometricsValueResponse.self)
        .result
        .get()
    }

    func deleteValue(_ key: String?) async throws -> ZKBiometricsValueResponse {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        if key != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[key]", value: key)])
        }

        if value != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[value]", value: value?.base64EncodedString())])
        }

        return try await AF.request(
            requestURL,
            method: .delete
        )
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(ZKBiometricsValueResponse.self)
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
    let value: String
}

struct ZKBiometricsValueResponse: Codable {
    let data: ZKBiometricsValueResponseData
}

struct ZKBiometricsValueResponseData: Codable {
    let id, type: String
    let attributes: ZKBiometricsValueResponseAttributes
}

struct ZKBiometricsValueResponseAttributes: Codable {
    let key, value: String
}
