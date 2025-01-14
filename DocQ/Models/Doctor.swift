import Foundation

struct DoctorList: Codable {
    let doctors: [Doctor]
}

struct Doctor: Codable, Identifiable {
    let id: String
    let name: String
    let specialization: String
    let experience: String
} 