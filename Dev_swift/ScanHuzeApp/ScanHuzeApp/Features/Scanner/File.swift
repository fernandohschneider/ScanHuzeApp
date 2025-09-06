import Foundation
import RoomPlan
import ARKit

final class RoomPlanService: NSObject, ObservableObject {
    // Sessão e view do RoomPlan
    let session = RoomCaptureSession()
    let sessionConfig = RoomCaptureSession.Configuration()
    @Published var isRunning = false
    @Published var lastCapturedRoom: CapturedRoom?

    override init() {
        super.init()
        session.delegate = self
        // Ex.: configurar se quer capturar objetos
        sessionConfig.captureScene = true
        sessionConfig.captureReality = true
    }

    func start() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        session.run(configuration: sessionConfig)
        isRunning = true
    }

    func pause() {
        session.pause()
        isRunning = false
    }

    func finish() {
        session.stop()
        isRunning = false
    }

    // MARK: - Export
    /// Gera os arquivos .usdz e .json na pasta Documents e retorna os URLs
    func exportCurrentScan() throws -> (usdz: URL, json: URL) {
        guard let room = lastCapturedRoom else {
            throw NSError(domain: "RoomPlanService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Nenhum ambiente capturado"])
        }

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let baseName = "scan_\(stamp)"

        let usdzURL = docs.appendingPathComponent("\(baseName).usdz")
        let jsonURL = docs.appendingPathComponent("\(baseName).json")

        // Exporta USDZ
        try room.export(to: usdzURL)

        // Exporta JSON (estrutura do RoomPlan)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(room)
        try data.write(to: jsonURL, options: .atomic)

        return (usdzURL, jsonURL)
    }
}

// MARK: - RoomCaptureSessionDelegate
extension RoomPlanService: RoomCaptureSessionDelegate {
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        // Atualiza continuamente o modelo (útil p/ HUD)
        lastCapturedRoom = room
    }

    func captureSession(_ session: RoomCaptureSession, didEndWith room: CapturedRoom, error: Error?) {
        // Garantia: quando termina, guarda o último
        lastCapturedRoom = room
    }
}
