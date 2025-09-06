import SwiftUI

struct AuthView: View {
    @EnvironmentObject var app: AppState
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("ScanHuzeApp").font(.largeTitle).bold()

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.3)))

                SecureField("Senha", text: $password)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.3)))

                Button {
                    app.isLoggedIn = true
                } label: {
                    Text("Entrar (modo dev)")
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Text("Depois trocamos por Firebase.").font(.footnote).foregroundColor(.gray)
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}
