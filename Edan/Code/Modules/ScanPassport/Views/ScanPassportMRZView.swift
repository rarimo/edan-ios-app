import SwiftUI

struct ScanPassportMRZView: View {
    let onNext: (String) -> Void

    var body: some View {
        VStack {
            Text("Scan Passport")
                .h4()
                .align()
                .padding()
            Spacer()
            ZStack {
                MRZScanView(onMrzKey: onNext)
                Image(Images.passportFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            }
            .frame(maxWidth: .infinity)
            Text("Move your passport page inside the border")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .frame(width: 250)
            Spacer()
        }
    }
}

#Preview {
    ScanPassportMRZView { _ in }
}
