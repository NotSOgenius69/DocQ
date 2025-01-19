# DocQ

DocQ is an iOS application designed to bridge the gap between patients and doctors. The app allows patients to ask health-related questions anonymously and enables registered doctors to respond with helpful advice. It ensures privacy and facilitates convenient communication.

## Features

### For Patients:
- **Anonymous Question Submission**: Patients can ask questions about their health concerns without revealing their identity.
- **View Doctor Profiles**: A list of available doctors is displayed for reference using JSON parsing.
- **User-Friendly Interface**: Easy-to-navigate UI for submitting and browsing questions and answers.

### For Doctors:
- **Reply to Questions**: Doctors can provide answers and guidance to patient queries.
- **Secure Authentication**: Only registered doctors can participate in the platform.

### General Features:
- **Firebase Authentication**: Ensures secure login and registration for both patients and doctors.
- **Firebase Realtime Database**: Efficiently stores user data, questions, and replies.
- **JSON Parsing**: Displays a list of available doctors to patients using structured data.

---

## Technologies Used
- **Swift**: Primary programming language for the iOS app.
- **Firebase Authentication**: To authenticate users securely.
- **Firebase Realtime Database**: For storing and retrieving data in real time.
- **JSON Parsing**: To parse and display available doctor profiles.
- **UIKit**: For building the app’s user interface.

---

## Getting Started

### Prerequisites
- Xcode (Version 14.0 or higher)
- iOS 14.0 or higher
- Firebase project configured (visit [Firebase Console](https://console.firebase.google.com))

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/NotSOgenius69/DocQ.git
   ```

2. Open the project in Xcode:
   ```bash
   open DocQ.xcodeproj
   ```

3. Install CocoaPods dependencies (if applicable):
   ```bash
   pod install
   ```

4. Set up Firebase:
   - Add your GoogleService-Info.plist file to the project.
   - Configure Firebase in the AppDelegate:
     ```swift
     import Firebase

     @main
     class AppDelegate: UIResponder, UIApplicationDelegate {
         func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
             FirebaseApp.configure()
             return true
         }
     }
     ```

5. Build and run the project on a simulator or physical device.

---

## Firebase Configuration

### Authentication
- Enable Email/Password Authentication in the Firebase Console.

### Realtime Database
- Structure:
  ```json
  {
    "users": {
      "uid1": {
        "role": "patient",
        "name": "Anonymous"
      },
      "uid2": {
        "role": "doctor",
        "name": "Dr. John Doe",
        "specialization": "Cardiology"
      }
    },
    "questions": {
      "question1": {
        "user": "uid1",
        "content": "What are the symptoms of diabetes?",
        "replies": {
          "reply1": {
            "user": "uid2",
            "content": "Common symptoms include frequent urination, excessive thirst, and fatigue."
          }
        }
      }
    }
  }
  ```

---

## App Screens

### 1. Login / Signup Screen
- Secure authentication for both patients and doctors.
<img width="576" alt="Login" src="https://github.com/user-attachments/assets/30a7f768-cb67-40b9-a02b-c342fc105d06" />
<img width="595" alt="Register" src="https://github.com/user-attachments/assets/767b8445-184e-47bd-9514-16191ad397ba" />

### 2. Home Screen (Patients)
- Allows patients to post questions anonymously.
![Ask a question](https://github.com/user-attachments/assets/588b71e7-2c22-4631-8bd3-a644f47cbe74)

- Displays a list of their questions and doctor replies.
<img width="545" alt="Questions Asked" src="https://github.com/user-attachments/assets/9928dcb3-557a-4eb0-8090-9c019d5f48a3" />


### 3. Home Screen (Doctors)
- Displays questions posted by patients.
<img width="634" alt="Patient Questions" src="https://github.com/user-attachments/assets/0a760c50-701b-4441-a73e-7b96363f510b" />

- Enables doctors to respond to questions.
<img width="563" alt="Reply to question" src="https://github.com/user-attachments/assets/ad0d91d5-cb00-4d3e-82ff-61fe396b5a9d" />

### 4. Available Doctors
- Shows a list of available doctors parsed from JSON.
<img width="612" alt="Available Doctors" src="https://github.com/user-attachments/assets/619884b0-f695-4f08-9166-07aa7fa7805e" />

---

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add feature name'`).
4. Push to the branch (`git push origin feature-name`).
5. Open a Pull Request.

