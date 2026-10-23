import SwiftUI
import FirebaseCore

@main
struct SmallBizOpsApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var store = MockDataStore()
    @StateObject private var auth = AuthStore()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch auth.stage {
                case .credentials:
                    LoginView()
                case .faceIDSetup:
                    FaceIDSetupView()
                case .authenticated:
                    RootView()
                }
            }
            .environmentObject(router)
            .environmentObject(store)
            .environmentObject(auth)
            .onChange(of: auth.stage) { _, stage in
                if stage == .authenticated {
                    store.start()
                } else if stage == .credentials {
                    store.stop()
                }
            }
            .onAppear {
                if auth.stage == .authenticated {
                    store.start()
                }
            }
        }
    }
}
