import SwiftUI
import RoomPlan

struct RoomScanView: View {
    let projectId: String
    @StateObject private var service = RoomPlanService()

    init(projectId: String = "debug-project") {   // ⬅️ padrão p/ DEV
        self.projectId = projectId
    }

    @State private var showShare = false
    @State private var exportedFiles: [URL] = []

    // estados/avisos
    @State private var errorMsg: String?
    @State private var successMsg: String?

    // travas
    @State private var isFinalized = false
    @State private var isExporting = false

    // upload
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0

    var body: some View {
        ZStack(alignment: .top) {
            RoomCaptureRepresentable(service: service)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // Botões
                HStack(spacing: 12) {
                    Button(service.isRunning ? "Pausar" : "Iniciar") {
                        guard !isExporting && !isUploading else { return }
                        service.isRunning ? service.pause() : service.start()
                        isFinalized = false
                    }
                    .padding(10).background(.thinMaterial).cornerRadius(10)

                    Button("Finalizar") {
                        guard !isExporting && !isUploading else { return }
                        service.finish()
                        isFinalized = true
                    }
                    .padding(10).background(.thinMaterial).cornerRadius(10)

                    Button(isUploading ? "Enviando..." : "Salvar na Nuvem") {
                        Task { await exportAndUpload() }
                    }
                    .padding(10).background(.thinMaterial).cornerRadius(10)
                    .disabled(isUploading)

                    Button(isExporting ? "Exportando..." : "Exportar") {
                        guard !isExporting else { return }
                        isExporting = true

                        // finalize antes de exportar (travinha)
                        if !isFinalized {
                            service.finish()
                            isFinalized = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                doExport()
                            }
                        } else {
                            doExport()
                        }
                    }
                    .padding(10).background(.thinMaterial).cornerRadius(10)
                    .disabled(isExporting)
                }

                // Barra de progresso do UPLOAD (apenas quando enviando)
                if isUploading {
                    VStack(spacing: 6) {
                        ProgressView(value: uploadProgress)
                            .progressViewStyle(.linear)
                        Text("\(Int(uploadProgress * 100))%")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 16)
        }
        // share local
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: exportedFiles)
        }
        // alerts
        .alert("Sucesso", isPresented: .constant(successMsg != nil)) {
            Button("OK") { successMsg = nil }
        } message: { Text(successMsg ?? "") }
        .alert("Erro", isPresented: .constant(errorMsg != nil)) {
            Button("OK") { errorMsg = nil }
        } message: { Text(errorMsg ?? "") }
        // ciclo de vida
        .onAppear {
            service.start()
            isFinalized = false
        }
        .onDisappear { service.pause() }
    }

    // EXPORTAÇÃO LOCAL (mantido)
    private func doExport() {
        do {
            let files = try service.exportCurrentScan()
            exportedFiles = [files.usdz, files.json]
            showShare = true
        } catch {
            errorMsg = error.localizedDescription
        }
        isExporting = false
    }

    // EXPORTA E SOBE PARA O FIREBASE (novo)
    private func exportAndUpload() async {
        guard !isUploading else { return }
        isUploading = true
        uploadProgress = 0

        // finalize antes de exportar (travinha)
        if !isFinalized {
            service.finish()
            isFinalized = true
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        }

        do {
            // 1) exporta local
            let files = try service.exportCurrentScan()

            // 2) cria scanId no Firestore
            let scanId = try await FirestoreService.shared.createScan(projectId: projectId)

            // 3) envia para Storage
            let base = "projects/\(projectId)/scans/\(scanId)/raw"
            var stepDone = 0.0
            let totalSteps = 2.0
            let tick: () -> Void = { stepDone += 1; uploadProgress = stepDone / totalSteps }

            // USDZ
            let usdzPath = "\(base)/scan.usdz"
            _ = try await FirebaseStorageService.shared.upload(file: files.usdz, to: usdzPath) { p in
                uploadProgress = (stepDone + p * 0.5) / totalSteps
            }
            tick()

            // JSON
            let jsonPath = "\(base)/scan.json"
            _ = try await FirebaseStorageService.shared.upload(file: files.json, to: jsonPath) { p in
                uploadProgress = (stepDone + p * 0.5) / totalSteps
            }
            tick()

            // 4) finaliza no Firestore
            try await FirestoreService.shared.finalizeScan(
                projectId: projectId,
                scanId: scanId,
                rawUSDZPath: usdzPath,
                rawJSONPath: jsonPath
            )

            successMsg = "Arquivos enviados para sua base ✅"
        } catch {
            errorMsg = error.localizedDescription
        }

        isUploading = false
    }
}

// Share sheet (mantido)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
