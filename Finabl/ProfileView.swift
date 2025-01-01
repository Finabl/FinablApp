//
//  ProfileView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/29/24.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isProfileActive: Bool // Use binding to dismiss the sheet
    @State private var displayName: String = "Displayname"
    @State private var username: String = "@username"
    @State private var description: String = "Description of Expert. Blah blah blah"
    @State private var friendsCount: Int = 0
    @State private var achievements: [String] = ["achievement", "achievement", "achievement", "achievement"]
    @State private var isLoading: Bool = true

    var userEmail: String // Pass the user's email

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    // Custom Header (No Default Navigation Bar)
                    HStack {
                        Button(action: {
                            isProfileActive = false // Dismiss ProfileView
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text(username)
                            .font(Font.custom("Anuphan-Medium", size: 18))
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: {
                            // More options action
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Profile Information
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80) // Placeholder for profile image

                        Text(displayName)
                            .font(Font.custom("Anuphan-Medium", size: 24))
                            .foregroundColor(.black)

                        Text(username)
                            .font(Font.custom("Anuphan-Light", size: 16))
                            .foregroundColor(.gray)

                        Text("\(friendsCount) friends")
                            .font(Font.custom("Anuphan-Light", size: 14))
                            .foregroundColor(.gray)

                        Text(description)
                            .font(Font.custom("Anuphan-Light", size: 14))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // Edit Profile Button
                    Button(action: {
                        // Edit Profile action
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.body)
                            Text("Edit Profile")
                                .font(Font.custom("Anuphan-Light", size: 16))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)

                    // Overview Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overview")
                            .font(Font.custom("Anuphan-Medium", size: 18))
                            .foregroundColor(.black)
                            .padding(.horizontal)

                        // Achievements Grid
                        HStack(spacing: 16) {
                            ForEach(achievements.indices, id: \.self) { index in
                                VStack {
                                    Text("5") // Placeholder for achievement count
                                        .font(Font.custom("Anuphan-Medium", size: 24))
                                        .foregroundColor(.black)

                                    Text(achievements[index])
                                        .font(Font.custom("Anuphan-Light", size: 14))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            .padding(.top) // Ensure no content overlaps with the status bar
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                fetchUserData()
            }
        }            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }

    private func fetchUserData() {
        guard let url = URL(string: "http://127.0.0.1:3000/api/users/user/\(userEmail)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.displayName = "\(json["firstName"] ?? "") \(json["lastName"] ?? "")"
                        self.username = "@\(json["userName"] ?? "username")"
                        self.description = json["description"] as? String ?? "No description provided"
                        self.friendsCount = (json["friends"] as? Int) ?? 0
                        self.achievements = (json["achievements"] as? [String]) ?? ["achievement"]
                        self.isLoading = false
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
}

#Preview {
    ProfileView(isProfileActive: .constant(true), userEmail: "mehdi@mehdi.us")
}
