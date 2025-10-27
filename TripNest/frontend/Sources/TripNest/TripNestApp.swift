import SwiftUI
import Firebase

@main
struct TripNestApp: App {
    @StateObject private var authState = AuthState()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authState.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

class AuthState: ObservableObject {
    @Published var isLoggedIn = false

    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            self.isLoggedIn = user != nil
        }
    }
}
