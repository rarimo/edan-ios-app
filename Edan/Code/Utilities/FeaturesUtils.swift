import Foundation

class FeaturesUtils {
    static func serializeFeatures(_ features: [Double]) -> Data {
        var resultData = Data()

        let transformedFeatures = features.map { Int($0 * pow(2, 50)) }

        for feature in transformedFeatures {
            let featureBytes = withUnsafeBytes(of: feature) { Data($0) }

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

    static func areFeaturesSimilar(_ features1: [Int], _ features2: [Int], _ threshold: Int = 50) -> Bool {
        let sum = zip(features1, features2).reduce(0) {
            let difference = ($1.0 - $1.1)

            return $0 + (difference * 2)
        }

        return sum < threshold
    }
}
