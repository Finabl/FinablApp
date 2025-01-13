//
//  SearchFriendModal.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/8/25.
//

import SwiftUI

struct SearchFriendModal: View {
    @Binding var isPresented: Bool // Controls whether the modal is shown
    @State private var username: String = ""
    @State private var isSearching: Bool = false
    @State private var searchResult: User? = nil
    @State private var errorMessage: String? = nil
    @State private var suggestedUsernames: [String] = [] // Suggestions for similar usernames
    var onChatCreated: (Message) -> Void // Callback for when a new chat is created

    var body: some View {
        NavigationView {
            VStack {
                // Username Input Field
                TextField("Enter username", text: $username)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .autocapitalization(.none)

                // Search Button
                Button(action: {
                    searchForFriend()
                }) {
                    Text("Search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .disabled(isSearching || username.isEmpty) // Disable while searching or if input is empty
                .opacity(isSearching || username.isEmpty ? 0.5 : 1.0)

                // Loading Indicator
                if isSearching {
                    ProgressView()
                        .padding()
                }

                // Search Result
                if let user = searchResult {
                    VStack {
                        Text("User Found: \(user.name)")
                            .font(Font.custom("Anuphan-Medium", size: 16))
                        Button(action: {
                            startNewChat(with: user)
                        }) {
                            Text("Start Chat")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                } else if let error = errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        if !suggestedUsernames.isEmpty {
                            Text("Did you mean?")
                                .font(.headline)
                                .padding(.top)
                            ForEach(suggestedUsernames, id: \.self) { suggestion in
                                Button(action: {
                                    username = suggestion
                                    searchForFriend() // Retry with the suggestion
                                }) {
                                    Text(suggestion)
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Search Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func startNewChat(with user: User) {
        // Create a new chat
        let newChat = Message(
            id: Int.random(in: 1000...9999),
            name: user.name,
            message: "Say hi!",
            isGroup: false
        )
        
        // Trigger the callback to add the new chat to the main view
        onChatCreated(newChat)
        
        // Dismiss the modal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPresented = false
        }
    }
    
    private func searchForFriend() {
        guard !username.isEmpty else {
            errorMessage = "Please enter a username."
            return
        }
        isSearching = true
        errorMessage = nil
        searchResult = nil
        suggestedUsernames = []

        // Replace with actual API call
        let urlString = "https://app.finabl.org/api/users/search?username=\(username)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isSearching = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(FriendSearchResponse.self, from: data)
                        if let user = response.user {
                            searchResult = user
                            errorMessage = nil
                        } else if !response.suggestions.isEmpty {
                            errorMessage = "User not found."
                            suggestedUsernames = response.suggestions
                        } else {
                            errorMessage = "User not found."
                        }
                    } catch {
                        print("Decoding Error:", error)
                        errorMessage = "An error occurred while processing the response."
                    }
                } else {
                    errorMessage = "User not found."
                }
            }
        }.resume()
    }
}

struct User: Codable {
    let id: String
    let name: String
}

struct FriendSearchResponse: Codable {
    let user: User?
    let suggestions: [String]
}


#Preview {
    SearchFriendModal(isPresented: .constant(true), onChatCreated: { _ in })
}
