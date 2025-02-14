import SwiftUI

import TensorFlowLite

class MLFace {
    static let shared = MLFace()

    func computeArcface(_ inputs: [Float]) throws -> [Float] {
        let tfile = NSDataAsset(name: "arcface")!.data

        let interpreter = try Interpreter(modelData: tfile)

        try interpreter.allocateTensors()

        var inputsData = Data()
        for input in inputs {
            inputsData.append(contentsOf: withUnsafeBytes(of: input) { Data($0) })
        }

        try interpreter.copy(inputsData, toInputAt: 0)

        try interpreter.invoke()

        let outputTensor = try interpreter.output(at: 0)

        let outputData = outputTensor.data

        var ouputArrayFloat = [Float](repeating: 0, count: outputData.count / MemoryLayout<Float>.stride)
        _ = ouputArrayFloat.withUnsafeMutableBytes { outputData.copyBytes(to: $0) }

        let sumOfsquere = ouputArrayFloat.reduce(0) { $0 + $1 * $1 }

        return ouputArrayFloat.map { $0 / sqrt(sumOfsquere) }
    }
}
