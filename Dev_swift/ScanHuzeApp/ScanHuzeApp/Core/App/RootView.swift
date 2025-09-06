import SwiftUI

struct RootView: View {
    @StateObject private var app = AppState()

    var body: some View {
        Group {
            if app.isLoggedIn {
                DashboardView()
                    .environmentObject(app)
            } else {
                AuthView()
                    .environmentObject(app)
            }
        }
        .onAppear {
            // ✔️ teste rápido do Firebase (pode remover depois)
            QuickFirebaseHealthCheck.run()
        }
    }
}
