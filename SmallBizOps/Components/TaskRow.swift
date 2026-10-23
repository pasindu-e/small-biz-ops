import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    var onEdit: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(task.isCompleted ? Color.appTeal : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(task.isCompleted ? Color.appTeal : Color(hex: "C5CFDB"), lineWidth: 1.5)
                        )
                        .frame(width: 23, height: 23)
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.appNavy)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.appRowTitle())
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .appMuted : .primary)
                HStack(spacing: 5) {
                    Text(task.time)
                    Text("·")
                    Text(task.relatedTo)
                }
                .font(.system(size: 9))
                .foregroundColor(.appMuted)
            }
            Spacer()
            StatusBadge(text: task.priority.rawValue, tone: task.priority.tone)
            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.appMuted)
                        .padding(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(13)
        .appCard(padding: 0)
    }
}
