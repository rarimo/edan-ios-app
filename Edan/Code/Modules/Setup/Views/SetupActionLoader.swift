import SwiftUI

struct SetupActionLoader<Task: SetupActionTask>: View {
    @State private var completedTasks: [Task] = []

    @State private var currentTask: Task = .allCases.first!

    @State private var progress: Double = 0

    var body: some View {
        VStack {
            Text("Processing action")
                .h4()
                .align()
                .padding()
            VStack {
                ForEach(Array(Task.allCases), id: \.rawValue) { task in
                    SetupActionLoaderEntry(task: task, completedTasks: $completedTasks, currentTask: $currentTask)
                }
            }
            Spacer()
        }
    }
}

struct SetupActionLoaderEntry<Task: SetupActionTask>: View {
    let task: Task

    @Binding var completedTasks: [Task]
    @Binding var currentTask: Task

    @State private var progress: Double = 0.5

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.componentPrimary)
            if isCompleted {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.componentPrimary)
            }
            if isProgressing {
                RoundedRectangle(cornerRadius: 24)
                    .frame(width: 366 * CGFloat(progress), height: 60)
                    .foregroundStyle(.primaryLighter)
                    .align()
            }
            HStack {
                Text(task.description)
                    .subtitle3()
                    .foregroundStyle(textColor)
                Spacer()
                Group {
                    if isCompleted {
                        Image(systemName: "checkmark")
                    } else if isProgressing {
                        Text("\(Int(progress * 100))%")
                            .subtitle3()
                    }
                }
                .foregroundStyle(.textPrimary)
            }
            .padding(.horizontal, 25)
        }
        .frame(width: 366, height: 60)
    }

    var isCompleted: Bool {
        completedTasks.contains(where: { $0.rawValue == task.rawValue })
    }

    var isProgressing: Bool {
        task.rawValue == currentTask.rawValue
    }

    var textColor: Color {
        if isCompleted {
            return .textPrimary
        } else if isProgressing {
            return .textPrimary
        } else {
            return .textSecondary
        }
    }
}

#Preview {
    SetupActionLoader<SetupRegisterTask>()
}
