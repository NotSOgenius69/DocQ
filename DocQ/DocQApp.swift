import SwiftUI
import FirebaseCore

// AppDelegate for Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        return true
    }
}

@main
struct DocQApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
} 
