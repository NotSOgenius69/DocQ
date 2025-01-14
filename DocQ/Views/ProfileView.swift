import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ProfileView: View {
    @State private var isShowingLogoutAlert = false
    @State private var isChangingPassword = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var changePasswordMessage: String?
    @State private var userName: String = "Loading..."
    @State private var errorMessage: String?



    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    if let user = Auth.auth().currentUser {
                        Text(user.email ?? "No email")
                    }
                }

                Section(header: Text("Name")) {
                                    if let errorMessage = errorMessage {
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                    } else {
                                        Text(userName)
                                    }
                    }

                Section {
                    Button(action: {
                        isChangingPassword = true
                    }) {
                        Text("Change Password")
                            .foregroundColor(.blue)
                    }
                }

                Section {
                    Button(action: {
                        isShowingLogoutAlert = true
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear{
                fetchUserName()
            }
            .alert(isPresented: $isShowingLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        try? Auth.auth().signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $isChangingPassword) {
                ChangePasswordView(isPresented: $isChangingPassword)
            }
        }
    }
    func fetchUserName() {
            guard let userId = Auth.auth().currentUser?.uid else {
                self.errorMessage = "User not logged in"
                return
            }

            let ref = Database.database().reference().child("users").child(userId)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: Any],
                   let name = data["name"] as? String {
                    self.userName = name
                } else {
                    self.errorMessage = "Name not found in database"
                }
            } withCancel: { error in
                self.errorMessage = "Error fetching user data: \(error.localizedDescription)"
            }
        }
}

struct ChangePasswordView: View {
    @Binding var isPresented: Bool
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Password")) {
                    SecureField("Enter current password", text: $currentPassword)
                }
                
                Section(header: Text("New Password")) {
                    SecureField("Enter new password", text: $newPassword)
                }
                
                Section(header: Text("Confirm New Password")) {
                    SecureField("Confirm new password", text: $confirmPassword)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        changePassword()
                    }) {
                        Text("Change Password")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Change Password")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    
    func changePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match."
            return
        }
        
        // Reauthenticate the user
        if let user = Auth.auth().currentUser, let email = user.email {
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    errorMessage = "Reauthentication failed: \(error.localizedDescription)"
                    return
                }
                
                // Update the password
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = "Password change failed: \(error.localizedDescription)"
                    } else {
                        errorMessage = nil
                        isPresented = false // Dismiss the sheet
                    }
                }
            }
        } else {
            errorMessage = "User not logged in."
        }
    }
}

#Preview {
    ProfileView()
}
