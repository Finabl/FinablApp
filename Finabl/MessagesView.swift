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
    @State private var messages: [Message] = [
        Message(id: 1, name: "Person", message: "Message message message", isGroup: false),
        Message(id: 2, name: "Person, Person", message: "Message message message", isGroup: true),
        Message(id: 3, name: "Person, Person", message: "Message message message", isGroup: true),
        Message(id: 4, name: "Person", message: "Message message message", isGroup: false),
        Message(id: 5, name: "Person", message: "Message message message", isGroup: false),
        Message(id: 6, name: "Person", message: "Message message message", isGroup: false)
    ]
    
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
                        // Add new message action
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
                .listStyle(PlainListStyle())
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarHidden(true) // Hide default navigation bar
        }
    }
    
    private var filteredMessages: [Message] {
        if searchText.isEmpty {
            return messages
        } else {
            return messages.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.message.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct Message: Identifiable {
    let id: Int
    let name: String
    let message: String
    let isGroup: Bool
}

#Preview {
    MessagesView()
}
