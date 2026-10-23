import SwiftUI

struct TasksView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @State private var tab = "Today"
    @State private var showingAddTask = false
    @State private var taskToEdit: TaskItem?
    @State private var taskToDelete: TaskItem?
    @State private var deleteErrorMessage: String?

    private let tabs = ["Today", "Upcoming", "Completed"]

    private var completedCount: Int { store.tasks.filter(\.isCompleted).count }
    private var visibleTasks: [TaskItem] {
        tab == "Completed" ? store.tasks.filter(\.isCompleted) : store.tasks.filter { !$0.isCompleted }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Tasks", onBack: { router.go(.home) }) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.appNavy)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.press)
                }

                segmented
                    .padding(.top, 4)

                progressSection
                    .padding(.top, 22)

                HStack {
                    Text(tab).font(.appSectionTitle())
                    Spacer()
                    Text("\(tab == "Completed" ? completedCount : store.tasks.count - completedCount) tasks")
                        .font(.appCaption()).foregroundColor(.appMuted)
                }
                .padding(.top, 22)
                .padding(.bottom, 10)

                if tab == "Completed" && completedCount == 0 {
                    emptyState
                } else {
                    ForEach(visibleTasks) { task in
                        TaskRow(task: task, onToggle: {
                            store.toggleTask(task)
                        }, onEdit: {
                            taskToEdit = task
                        })
                        .contextMenu {
                            Button {
                                taskToEdit = task
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                taskToDelete = task
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .padding(.bottom, 9)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .animation(.easeInOut, value: store.tasks.map(\.isCompleted))
        .sheet(isPresented: $showingAddTask) {
            AddEditTaskView().environmentObject(store)
        }
        .sheet(item: $taskToEdit) { task in
            AddEditTaskView(taskToEdit: task).environmentObject(store)
        }
        .alert("Delete Task?", isPresented: Binding(get: { taskToDelete != nil }, set: { if !$0 { taskToDelete = nil } })) {
            Button("Cancel", role: .cancel) { taskToDelete = nil }
            Button("Delete", role: .destructive) {
                guard let task = taskToDelete else { return }
                store.deleteTask(task) { result in
                    if case .failure(let error) = result {
                        deleteErrorMessage = error.localizedDescription
                    }
                    taskToDelete = nil
                }
            }
        } message: {
            Text("This removes \"\(taskToDelete?.title ?? "this task")\" permanently.")
        }
        .alert("Couldn't Delete Task", isPresented: Binding(get: { deleteErrorMessage != nil }, set: { if !$0 { deleteErrorMessage = nil } })) {
            Button("OK") { deleteErrorMessage = nil }
        } message: {
            Text(deleteErrorMessage ?? "")
        }
    }

    private var segmented: some View {
        HStack(spacing: 2) {
            ForEach(tabs, id: \.self) { item in
                Button {
                    tab = item
                } label: {
                    Text(item)
                        .font(.system(size: 10, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 33)
                        .foregroundColor(tab == item ? .appNavy : .appMuted)
                        .background(tab == item ? Color.white : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .shadow(color: tab == item ? AppShadow.card : .clear, radius: 7, y: 2)
                }
                .buttonStyle(.press)
            }
        }
        .padding(3)
        .background(Color(hex: "E9EDF2"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(completedCount) of \(store.tasks.count) complete").font(.system(size: 18, weight: .bold))
                    Text("A focused day is a good day.").font(.appCaption()).foregroundColor(.appMuted)
                }
                Spacer()
                ZStack {
                    Circle().stroke(Color.appTeal, lineWidth: 3).frame(width: 43, height: 43)
                    Circle().fill(Color(hex: "E0F7F3")).frame(width: 37, height: 37)
                    Text("\(completedCount)/\(store.tasks.count)").font(.system(size: 10, weight: .bold)).foregroundColor(Color(hex: "087968"))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "E2E7ED")).frame(height: 5)
                    Capsule().fill(Color.appTeal)
                        .frame(width: geo.size.width * (store.tasks.isEmpty ? 0 : CGFloat(completedCount) / CGFloat(store.tasks.count)), height: 5)
                        .animation(.easeInOut(duration: 0.3), value: completedCount)
                }
            }
            .frame(height: 5)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: "E6EAF0")).frame(width: 50, height: 50)
                Image(systemName: "checkmark").font(.system(size: 20)).foregroundColor(.appMuted)
            }
            Text("Nothing completed yet").font(.appRowTitle())
            Text("Finish a task and it'll appear here.").font(.appCaption()).foregroundColor(.appMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 55)
    }
}

#Preview {
    TasksView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
