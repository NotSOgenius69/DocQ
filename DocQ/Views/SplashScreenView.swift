import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            RootView()
        } else {
            VStack {
                Image("docq_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
#Preview {
    SplashScreenView()
}

