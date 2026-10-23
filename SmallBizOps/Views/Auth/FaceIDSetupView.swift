import SwiftUI

struct FaceIDSetupView: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var store: MockDataStore
    @State private var scanState: ScanState = .idle
    @State private var errorText: String?

    private enum ScanState { case idle, scanning, success }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

            iconBadge
                .padding(.bottom, 22)

            Text(titleText)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.appNavy)
                .multilineTextAlignment(.center)

            Text(subtitleText)
                .font(.system(size: 13))
                .foregroundColor(.appMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 8)
                .frame(maxWidth: 300)

            toggleCard
                .padding(.top, 28)

            if let errorText {
                Text(errorText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.appDanger)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
            }

            Spacer(minLength: 40)

            PrimaryButton(title: continueTitle, style: .dark) {
                auth.completeLogin()
            }
            .disabled(scanState == .scanning)
            .opacity(scanState == .scanning ? 0.6 : 1)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(Color.appOffWhite)
    }

    private var titleText: String {
        scanState == .success ? "Face ID enabled" : "Secure your account"
    }

    private var subtitleText: String {
        switch scanState {
        case .idle:
            return "Turn on Face ID to sign in faster next time, or continue without it."
        case .scanning:
            return "Look at your device to confirm it's you."
        case .success:
            return "You'll be able to use Face ID the next time you sign in."
        }
    }

    private var continueTitle: String {
        scanState == .scanning ? "Scanning…" : "Continue"
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(badgeColor.opacity(0.12))
                .frame(width: 128, height: 128)
            Circle()
                .fill(LinearGradient(colors: [.appIndigo, .appTeal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 84, height: 84)
            Image(systemName: scanState == .success ? "checkmark" : "faceid")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(.appNavy)
        }
        .animation(.easeInOut(duration: 0.2), value: scanState)
    }

    private var badgeColor: Color {
        scanState == .success ? .appSuccess : .appIndigo
    }

    private var toggleCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Color.appIce)
                    .frame(width: 38, height: 38)
                Image(systemName: "faceid").font(.system(size: 17)).foregroundColor(.appBlue)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Enable Face ID").font(.appRowTitle())
                Text(store.faceIDEnabled ? "Enabled" : "Disabled").font(.appCaption()).foregroundColor(.appMuted)
            }
            Spacer()
            if scanState == .scanning {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .appIndigo))
            } else {
                Toggle("", isOn: $store.faceIDEnabled)
                    .labelsHidden()
                    .tint(.appTeal)
                    .onChange(of: store.faceIDEnabled) { _, isOn in
                        if isOn {
                            startScan()
                        } else {
                            scanState = .idle
                            errorText = nil
                        }
                    }
            }
        }
        .padding(13)
        .appCard(padding: 0)
    }

    private func startScan() {
        errorText = nil
        scanState = .scanning
        auth.authenticateWithFaceID { success, message in
            if success {
                scanState = .success
            } else {
                scanState = .idle
                store.faceIDEnabled = false
                errorText = message
            }
        }
    }
}

#Preview {
    FaceIDSetupView().environmentObject(AuthStore()).environmentObject(MockDataStore())
}
