import SwiftUI

struct AvailableDoctorsView: View {
    @State private var doctors: [Doctor] = []
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text("Available Doctors")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.top, 40)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(doctors) { doctor in
                                    DoctorCardView(doctor: doctor)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    loadDoctors()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func loadDoctors() {
        guard let url = Bundle.main.url(forResource: "doctors", withExtension: "json") else {
            errorMessage = "Could not find doctors.json"
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let doctorList = try JSONDecoder().decode(DoctorList.self, from: data)
            doctors = doctorList.doctors
        } catch {
            errorMessage = "Error loading doctors: \(error.localizedDescription)"
        }
    }
}

struct DoctorCardView: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(doctor.name)
                .font(.headline)
            
            HStack {
                Image(systemName: "stethoscope")
                    .foregroundColor(.blue)
                Text(doctor.specialization)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text(doctor.experience)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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
    AvailableDoctorsView()
} 