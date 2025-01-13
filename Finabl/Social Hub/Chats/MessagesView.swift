//
//  MessagesView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/2/25.
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.presentationMode) var presentationMode // For back button functionality
    @State private var searchText: String = ""
    @State private var messages: [Message] = [] // Dynamically fetch messages
    @State private var isChatViewActive: Bool = false
    @State private var selectedChat: Message?
    @State private var isSearchModalActive: Bool = false // To show the search modal
    
    var body: some View {
        NavigationView {
            VStack {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Messages")
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {
                        isSearchModalActive = true // Open the modal
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Search Bar
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Messages List
                List {
                    ForEach(filteredMessages) { message in
                        Button(action: {
                            selectedChat = message
                            isChatViewActive = true
                        }) {
                            HStack(spacing: 10) {
                                Group {
                                    if message.isGroup {
                                        Image(systemName: "person.2.fill")
                                            .resizable()
                                            .scaledToFit()
                                    } else {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(message.name)
                                        .font(Font.custom("Anuphan-Medium", size: 16))
                                        .foregroundColor(.primary)
                                    Text(message.message)
                                        .font(Font.custom("Anuphan-Regular", size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarHidden(true) // Hide default navigation bar
            .onAppear(perform: fetchMessages) // Fetch messages when the view appears
            .background(
                NavigationLink(
                    destination: ChatView(chat: selectedChat),
                    isActive: $isChatViewActive,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .sheet(isPresented: $isSearchModalActive) {
                SearchFriendModal(isPresented: $isSearchModalActive, onChatCreated: { newChat in
                    messages.insert(newChat, at: 0) // Add the new chat to the top of the list
                    selectedChat = newChat
                    isChatViewActive = true // Open the chat view
                })
            }
        }
    }
    
    private var filteredMessages: [Message] {
        if searchText.isEmpty {
            return messages
        } else {
            return messages.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.message.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private func fetchMessages() {
        // Fetch messages from the API
        guard let url = URL(string: "https://app.finabl.org/api/chat/get_chats") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            if let fetchedMessages = try? JSONDecoder().decode([Message].self, from: data) {
                DispatchQueue.main.async {
                    messages = fetchedMessages
                }
            }
        }.resume()
    }
}

struct Message: Identifiable, Codable {
    let id: Int
    let name: String
    let message: String
    let isGroup: Bool
}

#Preview {
    MessagesView()
}
