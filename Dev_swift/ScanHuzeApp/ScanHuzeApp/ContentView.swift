import SwiftUI

struct ContentView: View {
    var body: some View {
        RoomScanView(projectId:"debug-project")
            .edgesIgnoringSafeArea(.all)
    }
}
