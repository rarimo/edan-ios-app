import Foundation

enum HistoryEntryType: Codable {
    case received, sent

    var description: String {
        switch self {
        case .received: return "Received"
        case .sent: return "Sent"
        }
    }
}

struct HistoryEntry: Codable, Identifiable {
    let id: UUID
    let type: HistoryEntryType
    let amount: String
}

extension MainView {
    class ViewModel: ObservableObject {
        @Published var historyEntries: [HistoryEntry] {
            didSet {
                if PreviewUtils.isPreview {
                    return
                }

                AppUserDefaults.shared.historyEntries = (try? JSONEncoder().encode(historyEntries)) ?? Data()
            }
        }

        init() {
            do {
                let historyEntries = AppUserDefaults.shared.historyEntries

                self.historyEntries = try JSONDecoder().decode([HistoryEntry].self, from: historyEntries)
            } catch {
                self.historyEntries = []
            }
        }

        func addNewHistoryEntry(type: HistoryEntryType, amount: Int) {
            let balance = Double(amount) / pow(10, Double(WalletManager.shared.decimals))
            let balanceString = String(format: "%.3f", balance)

            let newEntry = HistoryEntry(id: UUID(), type: type, amount: balanceString)

            historyEntries.append(newEntry)
        }

        func addNewHistoryEntry(type: HistoryEntryType, amount: Double) {
            let balanceString = String(format: "%.3f", amount)

            let newEntry = HistoryEntry(id: UUID(), type: type, amount: balanceString)

            historyEntries.append(newEntry)
        }
    }
}
