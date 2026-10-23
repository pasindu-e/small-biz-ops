import SwiftUI
import LocalAuthentication
import FirebaseAuth

enum AuthStage: Equatable {
    case credentials
    case faceIDSetup
    case authenticated
}

@MainActor
final class AuthStore: ObservableObject {
    @Published var stage: AuthStage = .credentials
    @Published var loginError: String?
    @Published var isCheckingBiometrics = false
    @Published var isSigningIn = false

    init() {
        stage = Auth.auth().currentUser != nil ? .authenticated : .credentials
    }

    /// Signs in with Firebase Authentication, then hands off to the Face ID
    /// enable/scan step rather than logging straight in.
    func signIn(username: String, password: String) {
        let email = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "Enter your email and password."
            return
        }

        loginError = nil
        isSigningIn = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            Task { @MainActor in
                guard let self else { return }
                self.isSigningIn = false
                if let error {
                    self.loginError = error.localizedDescription
                    return
                }
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.stage = .faceIDSetup
                }
            }
        }
    }

    /// Runs a real biometric prompt (works in Simulator via Features > Face ID)
    /// and reports success/failure without changing navigation state itself.
    func authenticateWithFaceID(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var evaluationError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evaluationError) else {
            completion(false, "Face ID is not available on this device.")
            return
        }

        isCheckingBiometrics = true
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign in to SmallBizOps") { [weak self] success, error in
            Task { @MainActor in
                self?.isCheckingBiometrics = false
                completion(success, success ? nil : "Face ID didn't match. Try again or continue without it.")
            }
        }
    }

    func completeLogin() {
        withAnimation(.easeInOut(duration: 0.25)) {
            stage = .authenticated
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        loginError = nil
        isCheckingBiometrics = false
        withAnimation(.easeInOut(duration: 0.25)) {
            stage = .credentials
        }
    }
}
