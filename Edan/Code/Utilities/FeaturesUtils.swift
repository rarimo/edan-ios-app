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

    static func areFeaturesSimilar(_ features1: [Double], _ features2: [Double], _ threshold: Double = 50) -> Bool {
        let sum = zip(features1, features2).reduce(0) {
            let difference = ($1.0 - $1.1)

            return $0 + (difference * 2)
        }

        return sum < threshold
    }

    static func calculateAverageFeatures(_ features: [[Double]]) -> [Double] {
        if features.isEmpty { return [] }

        var averageFeatures = [Double](repeating: 0, count: features[0].count)
        for feature in features {
            for index in 0 ..< feature.count {
                averageFeatures[index] += feature[index]
            }
        }

        return averageFeatures.map { $0 / Double(features.count) }
    }
}
