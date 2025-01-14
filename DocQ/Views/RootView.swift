import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct RootView: View {
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @State private var userType: String = ""
    
    var body: some View {
        Group {
            if isLoggedIn {
                if userType == "Doctor" {
                    DoctorTabView(isLoggedIn: $isLoggedIn)
                } else {
                    MainTabView(isLoggedIn: $isLoggedIn)
                }
            } else {
                AuthView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // Listen to authentication state changes
            Auth.auth().addStateDidChangeListener { _, user in
                isLoggedIn = (user != nil)
                if let userId = user?.uid {
                    fetchUserType(userId: userId)
                } else {
                    userType = ""
                }
            }
        }
    }
    
    private func fetchUserType(userId: String) {
        let ref = Database.database().reference().child("users").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let userData = snapshot.value as? [String: Any],
               let type = userData["userType"] as? String {
                userType = type
            }
        }
    }
}

#Preview {
    RootView()
}
