import SwiftUI

struct AddPassportRecoveryView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        withCloseButton {
            ScanPassportView { passport in
                try? AppKeychain.setValue(.passportJson, passport.json)

                AlertManager.shared.emitSuccess("New recovery method added sucessfully")

                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 75)
        }
    }

    func withCloseButton(_ body: () -> some View) -> some View {
        ZStack(alignment: .topLeading) {
            body()
            VStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.componentPrimary)
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                    }
                }
                .frame(width: 40, height: 40)
            }
            .padding()
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: AddPassportRecoveryView.init)
}
