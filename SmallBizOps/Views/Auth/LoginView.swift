import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthStore
    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field { case username, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, 56)
                    .padding(.bottom, 32)

                VStack(alignment: .leading, spacing: 14) {
                    fieldLabel("Email")
                    inputField(
                        text: $username,
                        placeholder: "you@business.com",
                        icon: "person",
                        isSecure: false,
                        field: .username
                    )

                    fieldLabel("Password")
                        .padding(.top, 4)
                    inputField(
                        text: $password,
                        placeholder: "••••••••",
                        icon: "lock",
                        isSecure: true,
                        field: .password
                    )

                    if let error = auth.loginError {
                        Text(error)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.appDanger)
                            .padding(.top, 2)
                    }

                    HStack {
                        Spacer()
                        Button("Forgot password?") {}
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.appBlue)
                            .buttonStyle(.press)
                    }
                    .padding(.top, 2)
                }
                .padding(.top, 4)

                PrimaryButton(title: auth.isSigningIn ? "Signing In…" : "Sign In", style: .dark) {
                    focusedField = nil
                    auth.signIn(username: username, password: password)
                }
                .disabled(auth.isSigningIn)
                .padding(.top, 22)

                dividerRow
                    .padding(.top, 22)
                    .padding(.bottom, 18)

                SocialButton(title: "Continue with Google", systemImage: "g.circle") {}
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.appOffWhite)
        .onTapGesture { focusedField = nil }
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [.appIndigo, .appTeal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                Image(systemName: "sparkles").font(.system(size: 27)).foregroundColor(.appNavy)
            }
            VStack(spacing: 4) {
                Text("SmallBizOps").font(.system(size: 24, weight: .bold)).foregroundColor(.appNavy)
                Text("Your Business Operations Agent").font(.appCaption()).foregroundColor(.appMuted)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .heavy))
            .tracking(0.8)
            .foregroundColor(.appLightMuted)
    }

    private func inputField(text: Binding<String>, placeholder: String, icon: String, isSecure: Bool, field: Field) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.appMuted)
                .frame(width: 18)
            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(field == .username ? .emailAddress : .default)
                }
            }
            .font(.system(size: 14))
            .focused($focusedField, equals: field)
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(focusedField == field ? Color.appIndigo : Color.appLine, lineWidth: focusedField == field ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var dividerRow: some View {
        HStack(spacing: 10) {
            Rectangle().fill(Color.appLine).frame(height: 1)
            Text("or continue with").font(.system(size: 10)).foregroundColor(.appMuted).fixedSize()
            Rectangle().fill(Color.appLine).frame(height: 1)
        }
    }
}

private struct SocialButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.appButton())
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .foregroundColor(.appSlate)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color(hex: "D8DEE8"), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.press)
    }
}

#Preview {
    LoginView().environmentObject(AuthStore())
}
