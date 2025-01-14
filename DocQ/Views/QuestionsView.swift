import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct QuestionsView: View {
    @State private var questions: [PatientQuestion] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingDeleteAlert = false
    @State private var questionToDelete: PatientQuestion?

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text("Questions Asked")
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
                                    CardView(question: question)
                                        .padding(.horizontal)
                                        .transition(.opacity)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                questionToDelete = question
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("Delete Question", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    refreshData()
                }
                .alert("Delete Question", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        if let question = questionToDelete {
                            deleteQuestion(question)
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete this question? This action cannot be undone.")
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func refreshData() {
        isLoading = true
        errorMessage = nil
        fetchQuestions()
    }

    private func deleteQuestion(_ question: PatientQuestion) {
        // Delete the question and its replies
        let questionRef = Database.database().reference().child("questions").child(question.id)
        let repliesRef = Database.database().reference().child("replies").child(question.id)
        
        let group = DispatchGroup()
        
        // Delete replies first
        group.enter()
        repliesRef.removeValue { error, _ in
            if let error = error {
                print("Error deleting replies: \(error.localizedDescription)")
            }
            group.leave()
        }
        
        // Then delete the question
        group.enter()
        questionRef.removeValue { error, _ in
            if let error = error {
                print("Error deleting question: \(error.localizedDescription)")
            }
            group.leave()
        }
        
        // After both operations complete, refresh the view
        group.notify(queue: .main) {
            refreshData()
        }
    }

    private func fetchQuestions() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            isLoading = false
            return
        }

        let ref = Database.database().reference().child("questions")
        ref.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value) { snapshot in
            if let questions = snapshot.value as? [String: [String: Any]] {
                var fetchedQuestions: [PatientQuestion] = []
                let group = DispatchGroup()
                
                for (questionId, questionData) in questions {
                    group.enter()
                    let title = questionData["title"] as? String ?? "No Title"
                    let description = questionData["description"] as? String ?? "No Description"
                    let timestamp = questionData["timestamp"] as? TimeInterval ?? 0
                    
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
                        
                        let question = PatientQuestion(
                            id: questionId,
                            title: title,
                            description: description,
                            timestamp: timestamp,
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
                self.errorMessage = "No questions found for this user."
                self.isLoading = false
            }
        }
    }
}

struct CardView: View {
    let question: PatientQuestion
    
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
                    Text("Doctor Replies")
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
            } else {
                Text("No replies yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: question.replies.isEmpty ? 130 : nil)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color.white)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    QuestionsView()
}


