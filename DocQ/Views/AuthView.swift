import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showRegister = false
    @State private var errorMessage: String = ""
    
    
    @Binding var isLoggedIn: Bool
    
    
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 20) {
                Image("docq_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                
            }
        }
    }
    
    func login() {
               errorMessage = ""
        
        // Check for valid email and password format
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                
                errorMessage = error.localizedDescription
            } else if result != nil {
                isLoggedIn = true
            }
        }
    }
}
#Preview{
    AuthView(isLoggedIn: .constant(true))
}
