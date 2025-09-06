import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth

// Inicialização do Firebase via AppDelegate (recomendado)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // Login anônimo para DEV (opcional)
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { _, err in
                if let err { print("Anon auth error:", err.localizedDescription) }
            }
        }
        return true
    }
}

@main
struct ScanHuzeApp: App {
    // Conecta o AppDelegate ao ciclo de vida do SwiftUI
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // SwiftData
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ Item.self ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView() // ou ContentView() se preferir
        }
        .modelContainer(sharedModelContainer)
    }
}
