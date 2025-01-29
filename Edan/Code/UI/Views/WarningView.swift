import SwiftUI

struct WarningView: View {
    let text: String

    @State private var isClosed = false

    var body: some View {
        if isClosed {
            EmptyView()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.warningLighter)
                HStack {
                    Text(text)
                        .body4()
                        .foregroundStyle(.warningDarker)
                        .align()
                        .frame(width: 302)
                    Button(action: { isClosed = true }) {
                        Image(systemName: "xmark")
                            .resizable()
                    }
                    .foregroundStyle(.textSecondary)
                    .frame(width: 8.5, height: 8.5)
                }
            }
            .frame(width: 350, height: 56)
        }
    }
}

#Preview {
    WarningView(text: "ZK Face technology is currently in beta, with balance limits in place")
}
