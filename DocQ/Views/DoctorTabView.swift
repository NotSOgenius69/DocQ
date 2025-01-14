import SwiftUI

struct DoctorTabView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        TabView {
            AnswerQuestionsView()
                .tabItem {
                    Image(systemName: "text.bubble.fill")
                    Text("Answer Questions")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    DoctorTabView(isLoggedIn: .constant(true))
} 