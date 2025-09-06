import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("🏗️ Escanear Obra", destination: RoomScanView(projectId: "debug-project"))
                NavigationLink("🎨 Design de Interiores", destination: Text("Em breve: funcionalidades de interiores"))
                NavigationLink("🏘️ Imobiliária", destination: Text("Em breve: funcionalidades de vendas e tour"))
            }
            .navigationTitle("ScanHuze")
        }
    }
}
