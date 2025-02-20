import Web3

import SwiftUI

protocol SetupActionTask: CaseIterable {
    var rawValue: Int { get }
    var description: String { get }
    var progressTime: Int { get }
}

enum SetupRecoveryTask: Int, SetupActionTask {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    case overridingAccess = 3
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKML"
        case .overridingAccess: return "Overriding access"
        }
    }
    
    var progressTime: Int {
        switch self {
        case .downloadingCircuitData: return 15
        case .extractionImageFeatures: return 5
        case .runningZKMK: return 10
        case .overridingAccess: return 7
        }
    }
}

enum SetupRegisterTask: Int, CaseIterable, SetupActionTask {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    case creatingAccount = 3
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKML"
        case .creatingAccount: return "Registering recovery method"
        }
    }
    
    var progressTime: Int {
        switch self {
        case .downloadingCircuitData: return 15
        case .extractionImageFeatures: return 5
        case .runningZKMK: return 10
        case .creatingAccount: return 7
        }
    }
}

class BiometryViewModel: ObservableObject {
    @Published var currentFrame: CGImage?
    @Published var faceImage: UIImage?

    var faceImages: [UIImage] = []
        
    private let cameraManager = BiomatryCaptureSession()
        
    @Published var cameraTask: Task<Void, Never>? = nil
        
    @Published var loadingProgress = 0.0
        
    @Published var recoveryProgress: SetupRecoveryTask? = nil
    @Published var registerProgress: SetupRegisterTask? = nil
        
    @Published var processingTask: Task<Void, Never>? = nil
        
    private var recentZKProofResult: Result<ZkProof, Error>?
        
    @MainActor
    func markRecoveryProgress(_ progress: SetupRecoveryTask) {
        recoveryProgress = progress
    }
    
    @MainActor
    func markRegisterProgress(_ progress: SetupRegisterTask) {
        registerProgress = progress
    }
        
    func startScanning() {
        cameraTask = Task {
            await cameraManager.startSession()
                
            await handleCameraPreviews()
        }
    }
        
    func stopScanning() {
        cameraManager.stopSession()
            
        cameraTask?.cancel()
    }
        
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
                    
                handleFaceImage(image)
            }
        }
    }
        
    func handleFaceImage(_ image: CGImage) {
        Task { @MainActor in
            do {
                if faceImage != nil {
                    return
                }
                    
                let faceImage = try ZKFaceManager.shared.extractFaceFromImage(UIImage(cgImage: image))
                guard let faceImage else {
                    if loadingProgress > 0 {
                        loadingProgress -= 0.01
                        
                        if faceImages.count > 0 {
                            faceImages.removeLast()
                        }
                    }
                        
                    return
                }
                    
                if loadingProgress >= 1 {
                    self.faceImage = faceImage
                    
                    stopScanning()
                        
                    return
                }
                
                faceImages.append(faceImage)
                    
                loadingProgress += 0.01
            } catch {
                LoggerUtil.common.error("Error extracting face: \(error)")
            }
        }
    }
    
    func addFaceRecoveryMethod(
        _ mainFaceImage: UIImage,
        _ accountAddress: String
    ) async throws {
        LoggerUtil.common.info("Adding the face recovery method")
        
        faceImages = [UIImage](faceImages.dropFirst(20))
        
        var imagesFeatures: [[Double]] = []
        var imagesSubFeatures: [[Double]] = []
        for image in faceImages {
            let (_, grayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(image)
            
            let computableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(grayscalePixelsData)

            let subFeatures = try ZKFaceManager.shared.extractFeaturesFromComputableModel(computableModel)
            
            imagesSubFeatures.append(subFeatures)
            
            let (_, rgbPixelsData) = try ZKFaceManager.shared.convertFaceToRgb(image)
            
            let rgbPixelsDataFloats = ZKFaceManager.shared.convertDataToMLInputs(rgbPixelsData)
            
            let features = try MLFace.shared.computeArcface(rgbPixelsDataFloats)
            
            imagesFeatures.append(features.map { Double($0) })
        }
        
        let similarFeaturesResponse = try await getSimilarFeatures(imagesFeatures)
        
        let features = FeaturesUtils.calculateAverageFeatures(imagesSubFeatures)
        
        if let similarFeaturesResponse {
            if FeaturesUtils.areFeaturesSimilar(features, similarFeaturesResponse.subfeatures) {
                throw "Face is already used"
            }
        } else {
            LoggerUtil.common.info("No similar features found")
        }
        
        let (_, mainGrayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(mainFaceImage)
        
        let mainComputableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(mainGrayscalePixelsData)
        
        let inputs = CircuitBuilderManager.shared.fisherFaceCircuit.buildInputs(mainComputableModel, features, 0)
        
        let zkProof = try await generateFisherface(inputs.json)
        let fisherfacePubSignals = FisherfacePubSignals(zkProof.pubSignals)
        
        if fisherfacePubSignals.getSignalRaw(.compirasionsResult) != "1" {
            throw "Face not recognized"
        }
        
        let zkFeatureHash = try fisherfacePubSignals.getSignal(.featuresHash)
        
        let setRecoveryMethodCalldata = try CalldataBuilderManager.shared.biometryAccount.setRecoveryMethod(zkProof)
        
        let response = try await ZKBiometricsSvc.shared.relay(setRecoveryMethodCalldata, accountAddress)
        
        LoggerUtil.common.info("Add the recovery method TX hash: \(response.data.attributes.txHash)")
        
        try await Ethereum().waitForTxSuccess(response.data.attributes.txHash)
        
        let averageFeatures = FeaturesUtils.calculateAverageFeatures(imagesFeatures)
        
        _ = try await ZKBiometricsSvc.shared.addValue2(averageFeatures, features)
        
        AppUserDefaults.shared.keyFaceFeatures = averageFeatures
        
        AccountManager.shared.saveFeaturesHash(zkFeatureHash.data())
    }
        
    func recoverByBiometry(_ mainFaceImage: UIImage) async throws {
        LoggerUtil.common.info("Start recover by biometry")
        
        faceImages = [UIImage](faceImages.dropFirst(20))

        var imagesFeatures: [[Double]] = []
        var imagesSubFeatures: [[Double]] = []
        for image in faceImages {
            let (_, grayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(image)
            
            let computableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(grayscalePixelsData)

            let subFeatures = try ZKFaceManager.shared.extractFeaturesFromComputableModel(computableModel)
            
            imagesSubFeatures.append(subFeatures)
            
            let (_, rgbPixelsData) = try ZKFaceManager.shared.convertFaceToRgb(image)
            
            let rgbPixelsDataFloats = ZKFaceManager.shared.convertDataToMLInputs(rgbPixelsData)
            
            let features = try MLFace.shared.computeArcface(rgbPixelsDataFloats)
            
            imagesFeatures.append(features.map { Double($0) })
        }
        
        guard let similarFeaturesResponse = try await getSimilarFeatures(imagesFeatures) else {
            throw "Account not found"
        }
        
        LoggerUtil.common.info("Account was found")
        
        let similarFeaturesHash = try FeaturesUtils.hashFeatures(similarFeaturesResponse.subfeatures)
        
        let accountAddress = try await AccountFactory.shared.getAccountByBioHash(similarFeaturesHash)
        
        let nonce = try await AccountFactory.shared.getRecoveryNonce(accountAddress)
        
        let (_, mainGrayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(mainFaceImage)
        
        let mainComputableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(mainGrayscalePixelsData)
        
        let inputs = CircuitBuilderManager.shared.fisherFaceCircuit.buildInputs(mainComputableModel, similarFeaturesResponse.subfeatures, Int(nonce))
        
        let zkProof = try await generateFisherface(inputs.json)
        let fisherfacePubSignals = FisherfacePubSignals(zkProof.pubSignals)
        
        if fisherfacePubSignals.getSignalRaw(.compirasionsResult) != "1" {
            throw "Face not recognized"
        }
        
        let zkFeatureHash = try fisherfacePubSignals.getSignal(.featuresHash)
        
        try AccountManager.shared.generateNewPrivateKey()
        
        let recoveryCalldata = try CalldataBuilderManager.shared.biometryAccount.recover(zkProof)
        
        let response = try await ZKBiometricsSvc.shared.relay(recoveryCalldata, accountAddress.hex(eip55: false))
        
        LoggerUtil.common.info("Recovery by biometry TX hash: \(response.data.attributes.txHash)")
        
        try await Ethereum().waitForTxSuccess(response.data.attributes.txHash)
        
        AppUserDefaults.shared.keyFaceFeatures = similarFeaturesResponse.feature
        
        AccountManager.shared.saveFeaturesHash(zkFeatureHash.data())
    }
        
    func generateFisherface(_ inputs: Data) async throws -> ZkProof {
        defer { self.recentZKProofResult = nil }
            
        let thread = Thread {
            do {
                let wtns = try ZKUtils.calcWtnsFisherface(inputs)

                let (proofJson, pubSignalsJson) = try ZKUtils.groth16Fisherface(wtns)

                let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
                let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
                    
                let zkProof = ZkProof(proof: proof, pubSignals: pubSignals)
                    
                self.recentZKProofResult = .success(zkProof)
            } catch {
                self.recentZKProofResult = .failure(error)
            }
                
            Thread.current.cancel()
        }
            
        thread.stackSize = 100 * 1024 * 1024
            
        thread.start()
            
        while recentZKProofResult == nil {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
        }
            
        switch recentZKProofResult {
        case .success(let proof):
            return proof
        case .failure(let error):
            throw error
        case .none:
            throw "failed to get proof"
        }
    }
    
    func getSimilarFeatures(_ features: [[Double]]) async throws -> ZKBiometricsValue2ResponseAttributes? {
        guard let response = try await ZKBiometricsSvc.shared.getValue2(features) else {
            return nil
        }
        
        return response.data.attributes
    }
    
    func clearImages() {
        faceImage = nil
        faceImages = []
    }
}

struct Exportable: Codable {
    let features: [Float]
    let rgbData: Data
}
