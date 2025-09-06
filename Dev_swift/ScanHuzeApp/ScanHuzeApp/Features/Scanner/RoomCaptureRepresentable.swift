import SwiftUI
import RoomPlan

struct RoomCaptureRepresentable: UIViewRepresentable {
    @ObservedObject var service: RoomPlanService

    func makeUIView(context: Context) -> RoomPlan.RoomCaptureView {
        let view = RoomPlan.RoomCaptureView(frame: .zero)
        // captureSession é get-only → pegamos a sessão criada pela view e anexamos ao service
        if let sess = view.captureSession {
            service.attach(session: sess)
        }
        return view
    }

    func updateUIView(_ uiView: RoomPlan.RoomCaptureView, context: Context) {}
}
