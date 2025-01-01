import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: signIn) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Sign In")
        }
    }

    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter all fields."
            return
        }

        // Firebase login
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            // User signed in successfully
            self.fetchUserData()
        }
    }

    private func fetchUserData() {
        // Create the URL
        guard let url = URL(string: "http://127.0.0.1:3000/api/users/user/\(email)") else {
            self.errorMessage = "Invalid URL"
            return
        }

        // Make the request
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from server"
                }
                return
            }

            // Print the response
            print("Server response: \(responseString)")

            // Dismiss the view on success
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        }.resume()
    }
}


#Preview {
    SignInView()
}
