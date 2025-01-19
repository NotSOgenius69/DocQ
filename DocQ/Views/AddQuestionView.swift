import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct AddQuestionView: View {
    @State private var selectedSpeciality: String = "Cardiologist"
    @State private var questionTitle: String = ""
    @State private var description: String = ""
    @State private var isLoading: Bool = false
    @State private var successMessage: String? = nil
    @State private var errorMessage: String? = nil
    
    let specialities = ["Cardiologist", "Pediatrician", "Neurologist", "Dermatologist", "Orthopedic Surgeon"]
    
    private var ref: DatabaseReference = Database.database().reference()

    var body: some View {
        VStack {
            Text("Ask a Question")
                .font(.largeTitle)
                .padding()

            VStack(alignment: .leading) {
                Text("Select Speciality")
                    .font(.headline)
                    .padding(.horizontal)
                
                Picker("Select Speciality", selection: $selectedSpeciality) {
                    ForEach(specialities, id: \.self) { speciality in
                        Text(speciality)
                            .tag(speciality)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
            }
            
            VStack(alignment: .leading) {
                Text("Question Title")
                    .font(.headline)
                    .padding(.horizontal)
                
                TextField("Brief title for your question", text: $questionTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            VStack(alignment: .leading) {
                Text("Question Details")
                    .font(.headline)
                    .padding(.horizontal)
                
                TextEditor(text: $description)
                    .frame(height: 200)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
            }

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
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Submit")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            questionTitle.isEmpty || description.isEmpty 
                            ? Color.gray 
                            : Color.blue
                        )
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading || questionTitle.isEmpty || description.isEmpty)
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

        // Create the full title with speciality
        let fullTitle = "\(selectedSpeciality): \(questionTitle)"

        // Create question dictionary with userId included
        let question: [String: Any] = [
            "title": fullTitle,
            "description": description,
            "timestamp": Int(Date().timeIntervalSince1970),
            "userId": currentUser.uid
        ]

        // Add to Firebase
        let questionsRef = ref.child("questions")
        let newQuestionRef = questionsRef.childByAutoId()

        newQuestionRef.setValue(question) { error, _ in
            isLoading = false
            
            if let error = error {
                errorMessage = "Error submitting question: \(error.localizedDescription)"
            } else {
                successMessage = "Question submitted successfully!"
                // Clear the form
                questionTitle = ""
                description = ""
                
                // Clear success message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    successMessage = nil
                }
            }
        }
    }
}

#Preview {
    AddQuestionView()
}

