import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct AnswerQuestionsView: View {
    @State private var questions: [DoctorQuestion] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedQuestion: DoctorQuestion?
    @State private var showingReplySheet = false
    @State private var replyText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text("Patient Questions")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .scaleEffect(2)
                            .padding(.top, 40)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 40)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(questions) { question in
                                    QuestionCardView(question: question) {
                                        selectedQuestion = question
                                        showingReplySheet = true
                                    }
                                    .padding(.horizontal)
                                    .transition(.opacity)
                                }
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    fetchAllQuestions()
                }
                .sheet(isPresented: $showingReplySheet) {
                    if let question = selectedQuestion {
                        ReplyView(question: question, isPresented: $showingReplySheet) {
                            // Refresh questions after reply
                            fetchAllQuestions()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func fetchAllQuestions() {
        isLoading = true
        errorMessage = nil
        
        let ref = Database.database().reference().child("questions")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let questions = snapshot.value as? [String: [String: Any]] {
                var fetchedQuestions: [DoctorQuestion] = []
                let group = DispatchGroup()
                
                for (questionId, questionData) in questions {
                    group.enter()
                    let title = questionData["title"] as? String ?? "No Title"
                    let description = questionData["description"] as? String ?? "No Description"
                    let timestamp = questionData["timestamp"] as? TimeInterval ?? 0
                    let userId = questionData["userId"] as? String ?? ""
                    
                    // Fetch replies for this question
                    let repliesRef = Database.database().reference().child("replies").child(questionId)
                    repliesRef.observeSingleEvent(of: .value) { repliesSnapshot in
                        var replies: [DocQReply] = []
                        if let repliesData = repliesSnapshot.value as? [String: [String: Any]] {
                            for (replyId, replyData) in repliesData {
                                let reply = DocQReply(
                                    id: replyId,
                                    text: replyData["text"] as? String ?? "",
                                    doctorId: replyData["doctorId"] as? String ?? "",
                                    doctorName: replyData["doctorName"] as? String ?? "",
                                    timestamp: replyData["timestamp"] as? TimeInterval ?? 0
                                )
                                replies.append(reply)
                            }
                        }
                        
                        let question = DoctorQuestion(
                            id: questionId,
                            title: title,
                            description: description,
                            timestamp: timestamp,
                            userId: userId,
                            replies: replies
                        )
                        fetchedQuestions.append(question)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.questions = fetchedQuestions.sorted(by: { $0.timestamp > $1.timestamp })
                    self.isLoading = false
                }
            } else {
                self.errorMessage = "No questions found."
                self.isLoading = false
            }
        }
    }
}

struct QuestionCardView: View {
    let question: DoctorQuestion
    let onReplyTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(question.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Divider()
            
            // Show replies section
            if !question.replies.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Replies")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ForEach(question.replies.sorted(by: { $0.timestamp > $1.timestamp })) { reply in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reply.doctorName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(reply.text)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        if reply.id != question.replies.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Button(action: onReplyTapped) {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("Reply")
                }
                .foregroundColor(.blue)
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color.white)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ReplyView: View {
    let question: DoctorQuestion
    @Binding var isPresented: Bool
    let onReplySubmitted: () -> Void
    
    @State private var replyText = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question")) {
                    Text(question.title)
                        .font(.headline)
                    Text(question.description)
                        .font(.subheadline)
                }
                
                Section(header: Text("Previous Replies")) {
                    if question.replies.isEmpty {
                        Text("No replies yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(question.replies.sorted(by: { $0.timestamp > $1.timestamp })) { reply in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(reply.doctorName)
                                    .font(.headline)
                                Text(reply.text)
                                    .font(.body)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                Section(header: Text("Your Reply")) {
                    TextEditor(text: $replyText)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: submitReply) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit Reply")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(replyText.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(replyText.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Reply to Question")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Submit") {
                    submitReply()
                }
                .disabled(replyText.isEmpty || isSubmitting)
            )
        }
    }
    
    private func submitReply() {
        guard let doctorId = Auth.auth().currentUser?.uid else {
            errorMessage = "Not logged in as a doctor"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        // First get the doctor's name
        let userRef = Database.database().reference().child("users").child(doctorId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let userData = snapshot.value as? [String: Any],
               let doctorName = userData["name"] as? String {
                
                // Create the reply data
                let replyData: [String: Any] = [
                    "text": replyText,
                    "doctorId": doctorId,
                    "doctorName": doctorName,
                    "timestamp": Int(Date().timeIntervalSince1970)
                ]
                
                // Add the reply to the database
                let repliesRef = Database.database().reference().child("replies").child(question.id)
                let newReplyRef = repliesRef.childByAutoId()
                
                newReplyRef.setValue(replyData) { error, _ in
                    isSubmitting = false
                    
                    if let error = error {
                        errorMessage = "Error submitting reply: \(error.localizedDescription)"
                    } else {
                        onReplySubmitted()
                        isPresented = false
                    }
                }
            } else {
                isSubmitting = false
                errorMessage = "Could not fetch doctor information"
            }
        }
    }
}

#Preview {
    AnswerQuestionsView()
} 