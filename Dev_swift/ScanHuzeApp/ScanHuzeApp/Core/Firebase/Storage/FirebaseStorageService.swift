import Foundation
import FirebaseStorage

final class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    private init() {}

    private let storage = Storage.storage()

    // Faz upload de um arquivo local para um path no Storage
    @discardableResult
    func upload(
        file: URL,
        to path: String,
        progress: @escaping (Double) -> Void = { _ in }
    ) async throws -> URL {
        let ref = storage.reference(withPath: path)
        let data = try Data(contentsOf: file)

        return try await withCheckedThrowingContinuation { cont in
            let task = ref.putData(data, metadata: nil) { _, err in
                if let err { cont.resume(throwing: err); return }
                ref.downloadURL { url, err in
                    if let err { cont.resume(throwing: err); return }
                    cont.resume(returning: url!)
                }
            }
            task.observe(.progress) { snap in
                let pct = Double(snap.progress?.fractionCompleted ?? 0)
                progress(pct)
            }
        }
    }
}
