import SwiftUI
import FirebaseAuth

struct NewProjectView: View {
    @EnvironmentObject var app: AppState

    @State private var name = ""
    @State private var selectedPlan: Plan = .compact
    @State private var areaLimit: Double = 150

    @State private var isCreating = false
    @State private var errorMsg: String?
    @State private var newProjectId: String?
    @State private var goScanner = false

    var body: some View {
        Form {
            Section("Identificação") {
                TextField("Nome do projeto", text: $name)
                    .textInputAutocapitalization(.words)
            }

            Section("Plano") {
                Picker("Plano", selection: $selectedPlan) {
                    ForEach(Plan.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            Section("Área inclusa") {
                Stepper(value: $areaLimit, in: 50...500, step: 10) {
                    Text("\(Int(areaLimit)) m² inclusos")
                }
                Text("Acima: +0,15€/m²")
                    .font(.footnote).foregroundColor(.gray)
            }

            Section {
                Button(isCreating ? "Criando..." : "Criar projeto") {
                    Task { await createProject() }
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
            }
        }
        .navigationTitle("Novo Projeto")
        .alert("Erro", isPresented: .constant(errorMsg != nil)) {
            Button("OK") { errorMsg = nil }
        } message: {
            Text(errorMsg ?? "")
        }
        // navegação automática para o scanner quando criar
        .background(
            NavigationLink(
                destination: RoomScanView(projectId: newProjectId ?? "debug-project"),
                isActive: $goScanner
            ) { EmptyView() }
            .hidden()
        )
    }

    // MARK: - Ações
    private func createProject() async {
        isCreating = true
        defer { isCreating = false }

        do {
            // guarda o rascunho local, como você já fazia
            app.currentProject = .init(
                name: name,
                plan: selectedPlan,
                areaLimit: areaLimit
            )

            // cria de fato no Firestore
            let uid = Auth.auth().currentUser?.uid
            let pid = try await FirestoreService.shared.createProject(
                name: name.trimmingCharacters(in: .whitespaces),
                plan: selectedPlan.key,                // <- chave limpa
                includedArea: Int(areaLimit),
                ownerUid: uid
            )

            // atualiza estado global e navega
            app.currentProjectId = pid
            newProjectId = pid
            goScanner = true
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}
