import Foundation

class FeaturesUtils {
    static func serializeFeatures(_ features: [Double]) -> Data {
        var resultData = Data()

        let transformedFeatures = features.map { Int($0 * pow(2, 50)) }

        for feature in transformedFeatures {
            var featureBytes = withUnsafeBytes(of: feature) { Data($0) }

            resultData.append(featureBytes)
        }

        return resultData
    }

    static func partlyDeserializeFeatures(_ data: Data) -> [Int] {
        var result: [Int] = []

        let featureSize = Int.bitWidth / 8

        for i in stride(from: 0, to: data.count, by: featureSize) {
            let featureBytes = data.subdata(in: i ..< i + featureSize)

            let feature = featureBytes.withUnsafeBytes { $0.load(as: Int.self) }

            result.append(feature)
        }

        return result
    }
}
