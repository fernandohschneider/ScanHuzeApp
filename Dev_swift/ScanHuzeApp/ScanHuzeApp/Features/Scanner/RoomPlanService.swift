import Foundation
import RoomPlan
import ARKit

final class RoomPlanService: NSObject, ObservableObject {
    @Published var isRunning = false
    @Published var lastCapturedRoom: CapturedRoom?

    private var session: RoomCaptureSession?
    private let configuration = RoomCaptureSession.Configuration()

    // A view (RoomCaptureView) cria a sessão. Aqui a gente "anexa" e vira delegate.
    func attach(session: RoomCaptureSession) {
        self.session = session
        self.session?.delegate = self
    }

    func start() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        guard let session else { return }
        session.run(configuration: configuration)
        isRunning = true
    }

    // RoomPlan não tem pause real — parar a sessão é o “pausar”
    func pause() {
        session?.stop()
        isRunning = false
    }

    func finish() {
        session?.stop()
        isRunning = false
    }

    // Exporta USDZ + JSON na pasta Documents/
    func exportCurrentScan() throws -> (usdz: URL, json: URL) {
        guard let room = lastCapturedRoom else {
            throw NSError(domain: "RoomPlanService", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Nenhum ambiente capturado. Finalize o scan antes de exportar."])
        }

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let base = "scan_\(stamp)"

        let usdzURL = docs.appendingPathComponent("\(base).usdz")
        let jsonURL = docs.appendingPathComponent("\(base).json")

        try room.export(to: usdzURL)

        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try enc.encode(room).write(to: jsonURL, options: .atomic)

        return (usdzURL, jsonURL)
    }
}

// MARK: - RoomCaptureSessionDelegate
extension RoomPlanService: RoomCaptureSessionDelegate {
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        lastCapturedRoom = room
    }
    // Evitamos outras variantes de didEndWith (mudam entre iOS).
}
