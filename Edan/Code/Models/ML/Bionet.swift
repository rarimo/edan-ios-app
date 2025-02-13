import SwiftUI

import TensorFlowLite

class Bionet {
    static let shared = Bionet()

    func compute(_ inputs: [Float]) throws -> [Float] {
        let tfile = NSDataAsset(name: "bionet_v3_new")!.data

        let interpreter = try Interpreter(modelData: tfile)

        try interpreter.allocateTensors()

        var inputsData = Data()
        for input in inputs {
            inputsData.append(contentsOf: withUnsafeBytes(of: input) { Data($0) })
        }

        try interpreter.copy(inputsData, toInputAt: 0)

        try interpreter.invoke()

        let outputTensor = try interpreter.output(at: 0)

        var outputData = outputTensor.data

        var ouputArrrayInt32 = [Float](repeating: 0, count: outputData.count / MemoryLayout<Float>.stride)
        _ = ouputArrrayInt32.withUnsafeMutableBytes { outputData.copyBytes(to: $0) }

        return ouputArrrayInt32
    }
}
