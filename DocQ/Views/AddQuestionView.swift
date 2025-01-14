import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct AddQuestionView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isLoading: Bool = false
    @State private var successMessage: String? = nil
    @State private var errorMessage: String? = nil
    
    private var ref: DatabaseReference = Database.database().reference()

    var body: some View {
        VStack {
            Text("Ask a Question")
                .font(.largeTitle)
                .padding()

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextEditor(text: $description)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()

            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: submitQuestion) {
                Text(isLoading ? "Submitting..." : "Submit")
                    .foregroundColor(.white)
                    .padding()
                    .background(isLoading ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(isLoading || title.isEmpty || description.isEmpty)
            .padding()

            Spacer()
        }
        .padding()
    }

    private func submitQuestion() {
        // Check if user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "You need to be logged in to submit a question."
            return
        }

        // Show loading state
        isLoading = true
        successMessage = nil
        errorMessage = nil

        // Create question dictionary with userId included
        let question: [String: Any] = [
            "title": title,
            "description": description,
            "timestamp": Int(Date().timeIntervalSince1970),
            "userId": currentUser.uid // Store the userId
        ]

        // Push question to Firebase Realtime Database
        ref.child("questions").childByAutoId().setValue(question) { error, _ in
            isLoading = false

            if let error = error {
                errorMessage = "Failed to submit question: \(error.localizedDescription)"
            } else {
                successMessage = "Your question has been submitted!"
                title = ""
                description = ""
            }
        }
    }
}

struct AddQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        AddQuestionView()
    }
}

