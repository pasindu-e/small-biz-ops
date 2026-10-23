import SwiftUI

struct AddEditTaskView: View {
    @EnvironmentObject var store: MockDataStore
    @Environment(\.dismiss) private var dismiss

    /// Pass an existing task to edit it; leave nil to create a new one.
    let taskToEdit: TaskItem?

    @State private var title: String
    @State private var relatedTo: String
    @State private var time: String
    @State private var priority: TaskPriority
    @State private var errorMessage: String?
    @State private var isSaving = false

    init(taskToEdit: TaskItem? = nil) {
        self.taskToEdit = taskToEdit
        _title = State(initialValue: taskToEdit?.title ?? "")
        _relatedTo = State(initialValue: taskToEdit?.relatedTo ?? "")
        _time = State(initialValue: taskToEdit?.time ?? "")
        _priority = State(initialValue: taskToEdit?.priority ?? .medium)
    }

    private var isEditing: Bool { taskToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("Related to (product, order, etc.)", text: $relatedTo)
                    TextField("Time (e.g. 10:00 AM, Today)", text: $time)
                    Picker("Priority", selection: $priority) {
                        ForEach([TaskPriority.high, .medium, .low], id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.appDanger)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") { save() }
                    }
                }
            }
            .disabled(isSaving)
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Enter a task title."
            return
        }

        var task = taskToEdit ?? TaskItem(title: trimmedTitle, relatedTo: "", time: "", priority: priority)
        task.title = trimmedTitle
        task.relatedTo = relatedTo.trimmingCharacters(in: .whitespacesAndNewlines)
        task.time = time.trimmingCharacters(in: .whitespacesAndNewlines)
        task.priority = priority

        isSaving = true
        let completion: (Result<Void, Error>) -> Void = { result in
            isSaving = false
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                errorMessage = "Couldn't save: \(error.localizedDescription)"
            }
        }

        if isEditing {
            store.updateTask(task, completion: completion)
        } else {
            store.addTask(task, completion: completion)
        }
    }
}

#Preview {
    AddEditTaskView().environmentObject(MockDataStore())
}
