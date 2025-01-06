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

    static func hashFeatures(_ features: [Double]) throws -> Data {
        if features.count != 39 {
            throw "Features count is not equal to 39"
        }

        let hashData = features.map { Int($0 * pow(2, 50)) }

        return try Poseidon.hash(
            [
                Poseidon.hash(
                    [
                        Poseidon.hashInt([hashData[0], hashData[1], hashData[2], hashData[3], hashData[4]]),
                        Poseidon.hashInt([hashData[5], hashData[6], hashData[7], hashData[8], hashData[9]]),
                        Poseidon.hashInt([hashData[10], hashData[11], hashData[12], hashData[13], hashData[14]]),
                        Poseidon.hashInt([hashData[15], hashData[16], hashData[17], hashData[18], hashData[19]])
                    ]
                ),
                Poseidon.hash(
                    [
                        Poseidon.hashInt([hashData[20], hashData[21], hashData[22], hashData[23], hashData[24]]),
                        Poseidon.hashInt([hashData[25], hashData[26], hashData[27], hashData[28], hashData[29]]),
                        Poseidon.hashInt([hashData[30], hashData[31], hashData[32], hashData[33], hashData[34]]),
                        Poseidon.hashInt([hashData[35], hashData[36], hashData[37], hashData[38]])
                    ]
                )
            ]
        )
    }
}
