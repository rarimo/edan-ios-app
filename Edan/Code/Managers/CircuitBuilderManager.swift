import Foundation
import Web3

class CircuitBuilderManager {
    static let shared = CircuitBuilderManager()

    let fisherFaceCircuit = FisherFaceCircuit()
}

extension CircuitBuilderManager {
    class FisherFaceCircuit {
        func buildInputs(
            _ model: [Double],
            _ features: [Double]
        ) -> FisherFaceInputs {
            return FisherFaceInputs(
                image: model.map { Int($0 * pow(2, 50)) },
                features: features.map { Int($0 * pow(2, 50)) },
                dummy: 0
            )
        }
    }
}
