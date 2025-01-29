import SwiftUI

struct UserProfileIconView: View {
    @EnvironmentObject private var userManager: UserManager

    @Environment(\.controlSize) var controlSize

    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    Circle()
                        .stroke(Color.warningLight, style: .init(lineWidth: progressCircleWidthSize))
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(Color.warningMain, style: .init(lineWidth: progressCircleWidthSize, lineCap: .round))
                }
                .foregroundStyle(.baseWhite)
                .frame(width: progressCircleSize, height: progressCircleSize)
                .rotationEffect(.degrees(-90))
                if let userFace = userManager.userFace {
                    Image(uiImage: userFace)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.circle)
                        .frame(width: imageSize, height: imageSize)
                }
            }
        }
    }

    var imageSize: CGFloat {
        switch controlSize {
        case .mini: 34
        case .regular: 114
        default: 114
        }
    }

    var progressCircleSize: CGFloat {
        switch controlSize {
        case .mini: 42
        case .regular: 140
        default: 140
        }
    }

    var progressCircleWidthSize: CGFloat {
        switch controlSize {
        case .mini: 4
        case .regular: 10
        default: 10
        }
    }

    var progress: CGFloat {
        CGFloat(0.33)
    }
}

#Preview {
    let userManager = UserManager.shared

    userManager.userFace = UIImage(named: Images.man)

    return VStack(spacing: 100) {
        UserProfileIconView()
            .controlSize(.regular)
        UserProfileIconView()
            .controlSize(.mini)
    }
    .environmentObject(userManager)
}
