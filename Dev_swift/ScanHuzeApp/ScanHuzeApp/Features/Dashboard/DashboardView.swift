import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            List {
                // criar novo projeto
                Section {
                    NavigationLink("➕ Novo Projeto") {
                        NewProjectView()
                    }
                }

                // atalhos (apenas para desenvolvimento)
                Section("Atalhos de desenvolvimento") {
                    NavigationLink("Abrir Scanner (dev)") {
                        // 🔑 por enquanto usa um id fixo
                        RoomScanView(projectId: "debug-project")
                        
                        // depois você pode trocar por algo do tipo:
                        // RoomScanView(projectId: app.currentProjectId ?? "debug-project")
                    }
                }
            }
            .navigationTitle("Projetos")
            .toolbar {
                Button(role: .destructive) {
                    app.isLoggedIn = false
                } label: {
                    Text("Sair")
                }
            }
        }
    }
}
