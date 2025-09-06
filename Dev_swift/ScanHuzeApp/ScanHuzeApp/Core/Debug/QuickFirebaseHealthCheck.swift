import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

enum QuickFirebaseHealthCheck {
    static func run() {
        // Firestore: grava um documento
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "ts": FieldValue.serverTimestamp(),
            "uid": Auth.auth().currentUser?.uid ?? "nil",
            "device": UIDevice.current.name
        ]
        db.collection("sanityChecks").addDocument(data: data) { err in
            if let err {
                print("❌ Firestore write failed:", err)
            } else {
                print("✅ Firestore write ok")
            }
        }

        // Storage: envia um txt pequenininho
        let ref = Storage.storage().reference()
            .child("debug/\(UUID().uuidString).txt")
        let body = "hello from ScanHuze".data(using: .utf8)!
        ref.putData(body) { _, err in
            if let err {
                print("❌ Storage upload failed:", err)
            } else {
                print("✅ Storage upload ok")
            }
        }
    }
}
