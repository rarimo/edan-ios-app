import SwiftUI

enum ProfileRecoveryFeatureState {
    case completed
    case interactive
    case unavailable
}

struct ProfileRecoveryFeatureView: View {
    let state: ProfileRecoveryFeatureState

    var body: some View {
        ZStack {
            if state == .unavailable {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.componentPrimary)
            }
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(backgroundColor)
        }
        .frame(width: 358, height: 72)
    }

    var backgroundColor: Color {
        switch state {
        case .completed:
            .componentPrimary
        case .interactive:
            .componentPrimary
        case .unavailable:
            .baseWhite
        }
    }
}

#Preview {
    VStack {
        ProfileRecoveryFeatureView(state: .completed)
        ProfileRecoveryFeatureView(state: .interactive)
        ProfileRecoveryFeatureView(state: .unavailable)
    }
}
