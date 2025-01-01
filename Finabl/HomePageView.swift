//
//  ContentView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/21/24.
//

import SwiftUI
import FirebaseAuth

struct HomePageView: View {
    @State private var userEmail: String? = nil // Tracks the user's email
    @State private var isProfileViewActive: Bool = false // Tracks navigation to ProfileView
    @State private var hasFinancialGoals: Bool = false // Tracks if financialGoals exist
    @State private var hasLearningGoals: Bool = false // Tracks if learningGoals exist

    var body: some View {
        TabView {
            // Home Tab
            NavigationStack {
                VStack {
                    // Display user's email or "Not signed in yet"
                    HStack {
                        Button(action: {
                            // Navigate to ProfileView
                            isProfileViewActive = true
                        }) {
                            Text(userEmail ?? "Not signed in yet")
                                .font(Font.custom("Anuphan-Light", size: 16))
                                .foregroundColor(userEmail != nil ? .blue : .gray)
                                .underline()
                                .padding()
                        }
                        .background(
                            NavigationLink(
                                destination: userEmail != nil
                                    ? ProfileView(isProfileActive: $isProfileViewActive, userEmail: userEmail!)
                                    : nil,
                                isActive: $isProfileViewActive,
                                label: { EmptyView() }
                            )
                            .hidden()
                        )
                        
                        Spacer()
                        
                        // Sign-Out Button
                        if userEmail != nil {
                            Button(action: {
                                signOut()
                            }) {
                                Text("Sign Out")
                                    .font(Font.custom("Anuphan-Light", size: 16))
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Navigation Links
                    NavigationLink(destination: OnboardingView()) {
                        Text("Sign Up")
                            .font(Font.custom("Anuphan-Light", size: 16))
                            .padding()
                    }
                    NavigationLink(destination: SignInView()) {
                        Text("Sign In")
                            .font(Font.custom("Anuphan-Light", size: 16))
                            .padding()
                    }
                    NavigationLink(destination: FinancialGoalsAssessmentView()) {
                        Text("Financial Goals Assessment")
                            .font(Font.custom("Anuphan-Light", size: 16))
                            .foregroundColor(userEmail == nil ? .gray : .blue)
                            .padding()
                    }
                    .disabled(userEmail == nil)

                    NavigationLink(destination: LearningGoalsAssessmentView()) {
                        Text("Learning Goals Assessment")
                            .font(Font.custom("Anuphan-Light", size: 16))
                            .foregroundColor(userEmail == nil ? .gray : .blue)
                            .padding()
                    }
                    .disabled(userEmail == nil)

                    NavigationLink(destination: PortfolioGenerationView()) {
                        Text("Create Portfolio")
                            .font(Font.custom("Anuphan-Light", size: 16))
                            .foregroundColor((!hasFinancialGoals || !hasLearningGoals) ? .gray : .blue)
                            .padding()
                    }
                    .disabled(!hasFinancialGoals || !hasLearningGoals)
                }
                .onAppear {
                    // Fetch global user data if available
                    if let user = Auth.auth().currentUser {
                        userEmail = user.email
                        print("Already signed in as \(user.email ?? "Unknown Email")")
                        fetchUserData(email: user.email!)
                    } else {
                        userEmail = nil
                        print("Not signed in.")
                        // Reset goals since the user is not signed in
                        hasFinancialGoals = false
                        hasLearningGoals = false
                    }
                }
                .padding()
            }
            .tabItem {
                VStack {
                    Image(systemName: "house.fill") // Replace with your custom icon
                    Text("Home")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }

            // Search Tab
            NavigationStack {
                VStack {
                    Text("Search")
                        .font(Font.custom("Anuphan-Light", size: 24))
                        .padding()
                }
            }
            .tabItem {
                VStack {
                    Image(systemName: "magnifyingglass") // Replace with your custom icon
                    Text("Search")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }

            // Learn Tab
            NavigationStack {
                VStack {
                    Text("Learn")
                        .font(Font.custom("Anuphan-Light", size: 24))
                        .padding()
                }
            }
            .tabItem {
                VStack {
                    Image(systemName: "book.fill") // Replace with your custom icon
                    Text("Learn")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }

            // Social Tab
            NavigationStack {
                VStack {
                    Text("Social")
                        .font(Font.custom("Anuphan-Light", size: 24))
                        .padding()
                }
            }
            .tabItem {
                VStack {
                    Image(systemName: "person.3.fill") // Replace with your custom icon
                    Text("Social")
                        .font(Font.custom("Anuphan-Light", size: 12))
                }
            }
        }
        .accentColor(Color.blue) // Set the tab bar selection color
    }

    // Sign-out function
    private func signOut() {
        do {
            try Auth.auth().signOut()
            userEmail = nil // Clear user email to refresh the view
            hasFinancialGoals = false
            hasLearningGoals = false
            print("User signed out successfully.")
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // Fetch user data to determine if goals exist
    private func fetchUserData(email: String) {
        let urlString = "http://localhost:3000/api/users/user/\(email)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let financialGoals = json["financialGoals"] as? [String: Any] {
                        hasFinancialGoals = true
                    } else {
                        hasFinancialGoals = false
                    }

                    if let learningGoals = json["learningGoals"] as? [String: Any] {
                        hasLearningGoals = true
                    } else {
                        hasLearningGoals = false
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    HomePageView()
}
