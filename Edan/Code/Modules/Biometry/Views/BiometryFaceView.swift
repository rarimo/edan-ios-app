import SwiftUI

enum BiometryProcess {
    case register
    case recovery
}

struct BiometryFaceView: View {
    @EnvironmentObject private var viewModel: BiometryViewModel

    var biometryProcess: BiometryProcess

    @State private var isScanning = false

    @State private var isScanned = false

    @State private var loadingCircleSize: CGFloat?

    @State private var loadingCircleCornerRadius: CGFloat = 150

    @State private var restoringTextDots: String = ""

    @State private var uiProcessingTask: Task<Void, Never>? = nil
    @State private var processingTask: Task<Void, Never>? = nil

    let onComplete: () -> Void
    let onError: (Error) -> Void

    var processingDescription: String {
        switch biometryProcess {
        case .register: return "Creating account"
        case .recovery: return "Restoring access"
        }
    }

    var body: some View {
        VStack {
            Spacer()
            Text(isScanned ? processingDescription + "\n" + restoringTextDots : "Scan your face")
                .h4()
                .multilineTextAlignment(.center)
                .padding(.bottom, isScanned ? 10 : 50)
                .padding(.horizontal)
            faceCircle
            Text("Look straight into the screen with good lighting conditions")
                .body2()
                .multilineTextAlignment(.center)
                .foregroundStyle(.textSecondary)
                .padding(.top, 40)
                .padding(.horizontal)
                .opacity(isScanned ? 0 : 1)
            Spacer()
            AppButton(
                text: "Continue",
                rightIcon: Icons.arrowRight,
                action: {
                    isScanning = true

                    viewModel.startScanning()
                }
            )
            .padding(.horizontal)
            .opacity(isScanning ? 0 : 1)
            .disabled(isScanning)
        }
        .onDisappear {
            processingTask?.cancel()
            uiProcessingTask?.cancel()

            viewModel.stopScanning()
        }
    }

    var faceCircle: some View {
        ZStack {
            Circle()
                .strokeBorder(.primaryDark, lineWidth: 5)
                .background(Circle().foregroundStyle(.primaryMain))
                .opacity(0.25)
            if let image = viewModel.currentFrame {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .clipped()
                    .scaleEffect(x: -1, y: 1)
                    .frame(maxWidth: 290, maxHeight: 290)
                if let loadingCircleSize {
                    if loadingCircleSize == 150 {
                        RoundedRectangle(cornerRadius: loadingCircleCornerRadius)
                            .foregroundStyle(.primaryMain)
                        BiometrySuccessView()
                        if isScanned {
                            switch biometryProcess {
                            case .register:
                                registerProcess
                            case .recovery:
                                recoveryProcess
                            }
                        }
                    } else {
                        Circle()
                            .strokeBorder(.primaryMain, lineWidth: loadingCircleSize)
                    }

                } else {
                    Circle()
                        .trim(from: 0.0, to: viewModel.loadingProgress)
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(.primaryMain)
                        .rotationEffect(.degrees(-90))
                }
            } else {
                Image(Icons.userFocus)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.primaryDark)
                    .frame(width: 75, height: 75)
            }
        }
        .onChange(of: viewModel.faceImage) { image in
            if image == nil {
                return
            }

            viewModel.stopScanning()

            Task { @MainActor in
                for newLoadingCircleSize in 6 ... 150 {
                    loadingCircleSize = CGFloat(newLoadingCircleSize)

                    try await Task.sleep(nanoseconds: 10_000_000)
                }

                for newCornerRadius in (25 ... 149).reversed() {
                    loadingCircleCornerRadius = CGFloat(newCornerRadius)

                    try await Task.sleep(nanoseconds: 20_000_000)
                }

                withAnimation {
                    isScanned = true
                }

                switch biometryProcess {
                case .register:
                    runRegisterProcess()
                case .recovery:
                    runRecoveryProcess()
                }

                while true {
                    try await Task.sleep(nanoseconds: 100_000_000)

                    if restoringTextDots.count == 30 {
                        restoringTextDots = ""
                    } else {
                        restoringTextDots += "."
                    }
                }
            }
        }
        .frame(width: 300, height: 300)
    }

    var registerProcess: some View {
        VStack(spacing: 35) {
            ForEach(SetupRegisterProgress.allCases, id: \.rawValue) { progress in
                VStack {
                    Text(progress.description)
                        .body2()
                        .align()
                        .foregroundStyle(.baseBlack)
                    BiometryProcessLoader(biometryRecoveryProgress: progress)
                }
                .padding(.horizontal)
            }
        }
        .transition(.opacity)
    }

    var recoveryProcess: some View {
        VStack(spacing: 35) {
            ForEach(SetupRecoveryProgress.allCases, id: \.rawValue) { progress in
                VStack {
                    Text(progress.description)
                        .body2()
                        .align()
                        .foregroundStyle(.baseBlack)
                    BiometryProcessLoader(biometryRecoveryProgress: progress)
                }
                .padding(.horizontal)
            }
        }
        .transition(.opacity)
    }

    func runRegisterProcess() {
        uiProcessingTask = Task { @MainActor in
            var isRecovered = false
            processingTask = Task {
                do {
                    try await viewModel.registerByBiometry()

                    isRecovered = true
                } catch {
                    onError(error)
                }
            }

            for progress in SetupRegisterProgress.allCases {
                viewModel.markRegisterProgress(progress)

                try? await Task.sleep(nanoseconds: UInt64(progress.progressTime) * NSEC_PER_SEC)
            }

            while !isRecovered {
                try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            }

            onComplete()
        }
    }

    func runRecoveryProcess() {
        uiProcessingTask = Task { @MainActor in
            guard let image = viewModel.faceImage else {
                return
            }

            var isRecovered = false
            processingTask = Task {
                do {
                    try await viewModel.recoverByBiometry(image)

                    isRecovered = true
                } catch {
                    onError(error)
                }
            }

            for progress in SetupRecoveryProgress.allCases {
                viewModel.markRecoveryProgress(progress)

                try? await Task.sleep(nanoseconds: UInt64(progress.progressTime) * NSEC_PER_SEC)
            }

            while !isRecovered {
                try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            }

            onComplete()
        }
    }
}

struct BiometryProcessLoader<Process: SetupActionProgress>: View {
    @EnvironmentObject var viewModel: BiometryViewModel

    var biometryRecoveryProgress: Process

    @State private var progress: Double = 0

    var body: some View {
        VStack {
            ProgressView(value: progress, total: 1)
                .progressViewStyle(.linear)
                .tint(.baseBlack)
        }
        .onChange(of: viewModel.recoveryProgress) { recoveryProgress in
            Task { @MainActor in
                if biometryRecoveryProgress.rawValue <= recoveryProgress?.rawValue ?? -1 {
                    while progress < 0.99 {
                        progress += 0.01

                        try await Task.sleep(nanoseconds: UInt64(biometryRecoveryProgress.progressTime) * NSEC_PER_SEC / 100)
                    }
                }
            }
        }
        .onChange(of: viewModel.registerProgress) { registerProgress in
            Task { @MainActor in
                if biometryRecoveryProgress.rawValue <= registerProgress?.rawValue ?? -1 {
                    while progress < 0.99 {
                        progress += 0.01

                        try await Task.sleep(nanoseconds: UInt64(biometryRecoveryProgress.progressTime) * NSEC_PER_SEC / 100)
                    }
                }
            }
        }
    }
}

#Preview {
    BiometryFaceView(biometryProcess: .register, onComplete: {}, onError: { _ in })
        .environmentObject(BiometryViewModel())
}
