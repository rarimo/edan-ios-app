import SwiftUI

protocol BiometryProgress {
    var rawValue: Int { get }
    var description: String { get }
    var progressTime: Int { get }
}

enum BiometryRecoveryProgress: Int, CaseIterable, BiometryProgress {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    case overridingAccess = 3
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKMK"
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

enum BiometryRegisterProgress: Int, CaseIterable, BiometryProgress {
    case downloadingCircuitData = 0
    case extractionImageFeatures = 1
    case runningZKMK = 2
    case creatingAccount = 3
    
    var description: String {
        switch self {
        case .downloadingCircuitData: return "Downloading circuit data"
        case .extractionImageFeatures: return "Extracting image features"
        case .runningZKMK: return "Running ZKMK"
        case .creatingAccount: return "Creating account"
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
        
    private let cameraManager = BiomatryCaptureSession()
        
    @Published var cameraTask: Task<Void, Never>? = nil
        
    @Published var loadingProgress = 0.0
        
    @Published var recoveryProgress: BiometryRecoveryProgress? = nil
    @Published var registerProgress: BiometryRegisterProgress? = nil
        
    @Published var processingTask: Task<Void, Never>? = nil
        
    private var recentZKProofResult: Result<ZkProof, Error>?
        
    @MainActor
    func markRecoveryProgress(_ progress: BiometryRecoveryProgress) {
        recoveryProgress = progress
    }
    
    @MainActor
    func markRegisterProgress(_ progress: BiometryRegisterProgress) {
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
                guard let faceImage = faceImage else {
                    if loadingProgress > 0 {
                        loadingProgress -= 0.01
                    }
                        
                    return
                }
                    
                if loadingProgress >= 1 {
                    self.faceImage = faceImage
                        
                    return
                }
                    
                loadingProgress += 0.01
            } catch {
                LoggerUtil.common.error("Error extracting face: \(error)")
            }
        }
    }
    
    func registerByBiometry(_ image: UIImage) async throws {
        let (_, grayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(image)

        let computableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(grayscalePixelsData)

        let features = ZKFaceManager.shared.extractFeaturesFromComputableModel(computableModel)

        let inputs = CircuitBuilderManager.shared.fisherFaceCircuit.buildInputs(computableModel, features)
            
        let _ = try await generateFisherface(inputs.json)
        
        try AccountManager.shared.generateNewPrivateKey()
    }
        
    func recoverByBiometry(_ image: UIImage) async throws {
        let (_, grayscalePixelsData) = try ZKFaceManager.shared.convertFaceToGrayscale(image)

        let computableModel = ZKFaceManager.shared.convertGrayscaleDataToComputableModel(grayscalePixelsData)

        let features = ZKFaceManager.shared.extractFeaturesFromComputableModel(computableModel)

        let inputs = CircuitBuilderManager.shared.fisherFaceCircuit.buildInputs(computableModel, features)
            
        let _ = try await generateFisherface(inputs.json)
        
        try AccountManager.shared.generateNewPrivateKey()
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
}