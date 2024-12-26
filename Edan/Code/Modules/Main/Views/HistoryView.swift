import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var viewModel: MainView.ViewModel

    var body: some View {
        VStack {
            Text("History")
                .align()
                .subtitle3()
            Divider()
            VStack {
                if viewModel.historyEntries.isEmpty {
                    Spacer()
                    Text("No history yet")
                        .body2()
                    Spacer()
                } else {
                    ScrollView {
                        ForEach(viewModel.historyEntries) { entry in
                            historyEntry(entry)
                            Divider()
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
    }

    func historyEntry(_ entry: HistoryEntry) -> some View {
        let iconName: String
        switch entry.type {
        case .received:
            iconName = Icons.arrowDown
        case .sent:
            iconName = Icons.arrowUp
        }

        return HStack {
            ZStack {
                Circle()
                    .foregroundStyle(.primaryLighter)
                Image(iconName)
                    .renderingMode(.template)
                    .foregroundStyle(.baseBlack)
            }
            .frame(width: 50, height: 50)
            Spacer()
            VStack {
                Text(WalletManager.shared.tokenName)
                    .subtitle3()
                    .align()
                Spacer()
                Text("\(entry.amount) \(entry.type.description) ")
                    .body2()
                    .align()
            }
        }
    }
}

#Preview {
    let viewModel = MainView.ViewModel()

    viewModel.addNewHistoryEntry(type: .received, amount: 534863596364313908)
    viewModel.addNewHistoryEntry(type: .sent, amount: 423863596364313908)

    return HistoryView()
        .environmentObject(viewModel)
}
