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
                    value: value
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

    func getValue(key: String? = nil, value: Data? = nil) async throws -> ZKBiometricsValueResponse? {
        var requestURL = url
        requestURL.append(path: "integrations/zk-biometrics-svc/value")

        if key != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[key]", value: key)])
        }

        if value != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[value]", value: value?.base64EncodedString())])
        }

        do {
            return try await AF.request(
                requestURL,
                method: .get
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

        if key != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[key]", value: key)])
        }

        if value != nil {
            requestURL.append(queryItems: [URLQueryItem(name: "filter[value]", value: value?.base64EncodedString())])
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
    let value: Data
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
    let value: Data
}
