//
//  ChatView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/8/25.
//

import SwiftUI
import FirebaseAuth
import SocketIO

struct ChatView: View {
    let chat: Message?
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    let manager = SocketManager(socketURL: URL(string: "https://app.finabl.org")!, config: [.log(true), .compress])
    private var socket: SocketIOClient {
        manager.defaultSocket
    }
    let apiBaseURL = "https://app.finabl.org/api/chat"
    let userBaseURL = "https://app.finabl.org/api/users"
    let currentUserEmail = FirebaseAuth.Auth.auth().currentUser?.email

    var body: some View {
        VStack {
            MessageList(messages: messages, currentUserEmail: currentUserEmail)
            InputBar(newMessage: $newMessage, sendMessageAction: sendMessage)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(chat?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupChat)
        .onDisappear(perform: closeSocketConnection)
    }

    func setupChat() {
        fetchMessages() // Fetch past messages
        setupSocketConnection() // Establish real-time connection
    }

    func setupSocketConnection() {
        guard let currentUserEmail = currentUserEmail else { return }
        let receiverEmail = chat?.name ?? ""

        socket.on(clientEvent: .connect) { _, _ in
            print("WebSocket connected")
            self.socket.emit("joinRoom", ["email": currentUserEmail])
        }

        socket.on("receiveMessage") { dataArray, _ in
            print("receiveMessage event triggered")
            guard let data = dataArray.first as? [String: Any],
                  let id = data["_id"] as? String,
                  let sender = data["sender"] as? String,
                  let receiver = data["receiver"] as? String,
                  let message = data["message"] as? String,
                  let timestamp = data["timestamp"] as? String else {
                print("Failed to parse received message")
                return
            }

            print("New message received: \(message)")
            let newMessage = ChatMessage(id: id, sender: sender, receiver: receiver, message: message, timestamp: timestamp)
            DispatchQueue.main.async {
                self.messages.append(newMessage)
                print("Message appended to UI: \(newMessage)")
            }
        }

        socket.on(clientEvent: .disconnect) { _, _ in
            print("WebSocket disconnected")
        }

        socket.connect()
    }



    func closeSocketConnection() {
        socket.disconnect()
    }

    func fetchMessages() {
        let receiverEmail = chat?.name ?? ""
        guard let senderEmail = fetchSenderEmail(),
              let fetchMessagesURL = URL(string: "\(apiBaseURL)/get_messages?user1Email=\(senderEmail)&user2Email=\(receiverEmail)") else { return }

        URLSession.shared.dataTask(with: fetchMessagesURL) { data, _, error in
            guard let data = data, error == nil else { return }
            if let fetchedMessages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
                DispatchQueue.main.async {
                    messages = fetchedMessages
                }
            }
        }.resume()
    }


    func sendMessage() {
        guard let sendMessageURL = URL(string: "\(apiBaseURL)/send_message"),
              let senderEmail = fetchSenderEmail() else {
            print("Invalid URL or sender email")
            return
        }
        let receiverEmail = chat?.name ?? ""

        let payload: [String: Any] = [
            "senderEmail": senderEmail,
            "receiverEmail": receiverEmail,
            "message": newMessage
        ]

        print("Sending message with payload: \(payload)")
        var request = URLRequest(url: sendMessageURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                if self.socket.status == .connected {
                    self.socket.emit("sendMessage", payload)
                    print("Message emitted via WebSocket")
                } else {
                    print("Socket not connected. Message not emitted")
                }
                self.newMessage = "" // Clear input field
            }
        }.resume()
    }




    func fetchSenderEmail() -> String? {
        if let email = FirebaseAuth.Auth.auth().currentUser?.email {
            return email
        }

        // Fallback: Fetch from `/me` endpoint
        guard let username = chat?.name,
              let url = URL(string: "\(userBaseURL)/me?username=\(username)") else { return nil }

        let semaphore = DispatchSemaphore(value: 0)
        var fetchedEmail: String?

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil,
               let response = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let email = response["email"] {
                fetchedEmail = email
            }
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return fetchedEmail
    }
}


struct MessageList: View {
    let messages: [ChatMessage]
    let currentUserEmail: String?

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages, id: \.id) { message in
                        HStack {
                            if message.sender == currentUserEmail {
                                Spacer()
                                MessageBubble(text: message.message, isCurrentUser: true)
                            } else {
                                MessageBubble(text: message.message, isCurrentUser: false)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .onChange(of: messages) { _ in
                scrollView.scrollTo(messages.last?.id, anchor: .bottom)
            }
        }
    }
}

struct MessageBubble: View {
    let text: String
    let isCurrentUser: Bool

    var body: some View {
        Text(text)
            .padding(12)
            .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(16)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isCurrentUser ? .trailing : .leading)
    }
}

struct InputBar: View {
    @Binding var newMessage: String
    let sendMessageAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                // Add attachment action
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }

            TextField("Enter message...", text: $newMessage)
                .padding(12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)

            Button(action: sendMessageAction) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white.shadow(radius: 1))
    }
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: String
    let sender: String
    let receiver: String
    let message: String
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case sender
        case receiver
        case message
        case timestamp
    }
}

#Preview {
    ChatView(chat: Message(id: 1, name: "Example Chat", message: "Last message", isGroup: false))
}
