import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var userType: String = "Patient" // Default selection
    @State private var userTypes = ["Doctor", "Patient"]
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Picker("User Type", selection: $userType) {
                ForEach(userTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: registerUser) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        
        
    }

    private func registerUser() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let userID = result?.user.uid else {
                errorMessage = "Failed to get user ID."
                return
            }

            // Save additional user data in Realtime Database
            let ref = Database.database().reference()
            let userData = ["name": name, "email": email, "userType": userType]

            ref.child("users").child(userID).setValue(userData) { error, _ in
                if let error = error {
                    errorMessage = "Failed to save user data: \(error.localizedDescription)"
                } else {
                    errorMessage = "Registration successful!"
                }
            }
        }
    }
}

#Preview{
    RegisterView()
}
