import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        TabView {
            QuestionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Questions")
                }
            
            AddQuestionView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add Question")
                }
            
            AvailableDoctorsView()
                .tabItem {
                    Image(systemName: "stethoscope")
                    Text("Doctors")
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
    MainTabView(isLoggedIn: .constant(true))
}
