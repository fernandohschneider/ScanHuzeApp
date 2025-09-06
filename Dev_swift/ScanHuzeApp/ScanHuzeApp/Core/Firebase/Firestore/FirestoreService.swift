import Foundation
import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // Cria um documento em /projects e retorna o projectId
    func createProject(
        name: String,
        plan: String,
        includedArea: Int,
        ownerUid: String?
    ) async throws -> String {
        let doc = db.collection("projects").document()
        var data: [String: Any] = [
            "name": name,
            "plan": plan,
            "includedArea": includedArea,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let ownerUid { data["ownerUid"] = ownerUid }

        try await doc.setData(data)
        return doc.documentID
    }

    // Cria um registro para um scan
    func createScan(projectId: String) async throws -> String {
        let doc = db.collection("projects").document(projectId)
            .collection("scans").document()
        try await doc.setData([
            "status": "created",
            "createdAt": FieldValue.serverTimestamp()
        ])
        return doc.documentID
    }

    // Finaliza o scan preenchendo paths no Storage
    func finalizeScan(
        projectId: String,
        scanId: String,
        rawUSDZPath: String,
        rawJSONPath: String
    ) async throws {
        let doc = db.collection("projects").document(projectId)
            .collection("scans").document(scanId)
        try await doc.setData([
            "status": "uploaded",
            "rawUSDZPath": rawUSDZPath,
            "rawJSONPath": rawJSONPath,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    // 🔹 Lista todos os projetos do usuário logado
    func listProjects(ownerUid: String) async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await db.collection("projects")
            .whereField("ownerUid", isEqualTo: ownerUid)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents
    }

    // 🔹 Lista todos os scans de um projeto
    func listProjectScans(projectId: String) async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await db.collection("projects")
            .document(projectId)
            .collection("scans")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents
    }
}
