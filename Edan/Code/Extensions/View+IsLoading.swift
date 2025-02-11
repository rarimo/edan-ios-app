import SwiftUI

extension View {
    @ViewBuilder func isLoading(_ isLoading: Bool, _ controlSize: ControlSize = .regular) -> some View {
        if isLoading {
            ProgressView()
                .controlSize(controlSize)
        } else {
            self
        }
    }
}
