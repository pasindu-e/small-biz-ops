import SwiftUI

struct BackHeader<Action: View>: View {
    let title: String
    let onBack: () -> Void
    @ViewBuilder var action: () -> Action

    init(title: String, onBack: @escaping () -> Void, @ViewBuilder action: @escaping () -> Action = { EmptyView() }) {
        self.title = title
        self.onBack = onBack
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
                    .foregroundColor(.primary)
            }
            .buttonStyle(.press)
            .accessibilityLabel("Go back")

            Spacer()
            Text(title)
                .font(.appRowTitle())
            Spacer()

            action()
                .frame(minWidth: 36, alignment: .trailing)
        }
        .frame(height: 46)
        .padding(.bottom, 10)
    }
}
