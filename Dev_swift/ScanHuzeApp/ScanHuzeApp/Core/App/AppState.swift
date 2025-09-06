import SwiftUI

final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false

    // rascunho local (continua igual ao seu)
    @Published var currentProject: ProjectDraft = .init()

    // 🔑 id do projeto criado no Firestore (usado para abrir o scanner)
    @Published var currentProjectId: String? = nil
}

struct ProjectDraft {
    var name: String = ""
    var plan: Plan = .compact
    var areaLimit: Double = 150.0
}

enum Plan: String, CaseIterable, Identifiable {
    case compact = "Compact (15€)"
    case plus    = "Plus (20€)"
    case premium = "Premium (30€)"
    var id: String { rawValue }

    /// chave “limpa” pra salvar no Firestore
    var key: String {
        switch self {
        case .compact: return "compact"
        case .plus:    return "plus"
        case .premium: return "premium"
        }
    }
}
