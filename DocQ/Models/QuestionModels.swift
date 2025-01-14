import Foundation

// Common reply model for both patient and doctor views
public struct DocQReply: Identifiable {
    public let id: String
    public let text: String
    public let doctorId: String
    public let doctorName: String
    public let timestamp: TimeInterval
}

// Model for patient's questions view
public struct PatientQuestion: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let timestamp: TimeInterval
    public let replies: [DocQReply]
}

// Model for doctor's questions view
public struct DoctorQuestion: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let timestamp: TimeInterval
    public let userId: String
    public let replies: [DocQReply]
} 