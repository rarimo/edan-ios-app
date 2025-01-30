import SwiftUI

enum ProfileRecoveryFeatureState {
    case completed
    case interactive
    case unavailable
}

struct ProfileRecoveryFeatureView: View {
    let state: ProfileRecoveryFeatureState

    let iconName: String
    let text: String

    let action: () -> Void

    var body: some View {
        ZStack {
            if state == .unavailable {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.componentPrimary)
            }
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(backgroundColor)
            HStack {
                Image(iconName)
                Text(text)
                    .subtitle3()
                    .foregroundStyle(textColor)
                    .padding(.leading, 5)
                Spacer()
                actionSlot
            }
            .padding(.horizontal, 30)
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

    var textColor: Color {
        switch state {
        case .completed:
            .textPrimary
        case .interactive:
            .textPrimary
        case .unavailable:
            .textDisabled
        }
    }

    var actionSlot: some View {
        VStack {
            switch state {
            case .completed:
                Image(systemName: "checkmark")
                    .foregroundStyle(.textSecondary)
            case .interactive:
                Button(action: action) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 1000)
                            .foregroundStyle(.primaryMain)
                        Text("Add")
                            .subtitle3()
                            .foregroundStyle(.baseBlack)
                    }
                    .frame(width: 56, height: 32)
                }
            case .unavailable:
                ZStack {
                    RoundedRectangle(cornerRadius: 1000)
                        .foregroundStyle(.componentPrimary)
                    Text("Soon")
                        .subtitle3()
                        .foregroundStyle(.textDisabled)
                }
                .frame(width: 56, height: 32)
            }
        }
    }
}

#Preview {
    VStack {
        ProfileRecoveryFeatureView(state: .completed, iconName: Icons.bodyScanLine, text: "ZK Face") {}
        ProfileRecoveryFeatureView(state: .interactive, iconName: Icons.passportLine, text: "Passport or ID") {}
        ProfileRecoveryFeatureView(state: .unavailable, iconName: Icons.accounPin, text: "Geolocation") {}
    }
}
