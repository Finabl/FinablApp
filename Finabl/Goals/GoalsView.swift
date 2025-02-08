//
//  GoalsView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 2/7/25.
//

import SwiftUI
import FirebaseAuth

struct Goal: Identifiable, Codable {
    var id: String  // 🔥 Use goalId from backend instead of generating UUID()
    var title: String
    var description: String
    var progress: Int
    var completed: Bool
    var goaltasks: [GoalTask]

    enum CodingKeys: String, CodingKey {
        case id = "goalId" // Map backend's goalId to Swift's id
        case goaltasks = "tasks"
        case title, description, progress, completed
    }
}

struct GoalTask: Identifiable, Codable {
    var id = UUID()  // Tasks don’t have unique backend IDs, so we generate UUIDs
    var name: String
    var completed: Bool

    enum CodingKeys: String, CodingKey {
        case name, completed
    }
}


struct GoalsView: View {
    @State private var goals: [Goal] = []
    @State private var newGoalTitle: String = ""
    @State private var newTaskTitle: String = ""
    @State private var goaltasks: [GoalTask] = []
    @State private var userEmail: String = ""
    
    let apiBaseUrl = "https://app.finabl.org/api/goals"
    
    var body: some View {
        VStack {
            if userEmail.isEmpty {
                Text("Loading...")
                    .onAppear {
                        fetchUserEmail()
                    }
            } else {
                Text("Goals for \(userEmail)")
                    .font(.headline)
                    .padding()
                
                // Input Fields for a New Goal
                TextField("Enter Goal Title", text: $newGoalTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    TextField("Enter Task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add Task") {
                        if !newTaskTitle.isEmpty {
                            goaltasks.append(GoalTask(name: newTaskTitle, completed: false))
                            newTaskTitle = ""
                        }
                    }
                }
                .padding()
                
                Button("Create Goal") {
                    createGoal()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                List {
                    ForEach(goals.indices, id: \.self) { goalIndex in
                        VStack(alignment: .leading) {
                            Text(goals[goalIndex].title).font(.headline)
                            
                            ProgressView(value: Double(goals[goalIndex].progress) / 100)
                                .padding(.bottom, 5)
                            
                            ForEach(goals[goalIndex].goaltasks.indices, id: \.self) { taskIndex in
                                HStack {
                                    Text(goals[goalIndex].goaltasks[taskIndex].name)
                                        .strikethrough(goals[goalIndex].goaltasks[taskIndex].completed, color: .gray)
                                        .foregroundColor(goals[goalIndex].goaltasks[taskIndex].completed ? .gray : .black)
                                    
                                    Spacer()
                                    Button(goals[goalIndex].goaltasks[taskIndex].completed ? "✔" : "Mark Complete") {
                                        markTaskComplete(goalIndex: goalIndex, taskIndex: taskIndex)
                                    }
                                    .disabled(goals[goalIndex].goaltasks[taskIndex].completed)
                                    .foregroundColor(goals[goalIndex].goaltasks[taskIndex].completed ? .gray : .blue)
                                }
                            }
                            
                            Button("Delete Goal") {
                                deleteGoal(goalId: goals[goalIndex].id)
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchGoals()
        }
    }
    
    // Fetch User Email from Firebase
    func fetchUserEmail() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? ""
            fetchGoals()
        }
    }
    
    // Fetch Goals from API
    func fetchGoals() {
        guard let url = URL(string: "\(apiBaseUrl)/get/\(userEmail)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, !data.isEmpty else {
                print("Error: API returned an empty response")
                return
            }
            
            do {
                // Convert raw data into a JSON object
                if let rawJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Raw API Response:", rawJson)
                    
                    // Extract "goals" array, but ensure it's a proper Swift array
                    if let goalsArray = rawJson["goals"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: goalsArray, options: [])
                        let decodedGoals = try JSONDecoder().decode([Goal].self, from: jsonData)
                        DispatchQueue.main.async {
                            self.goals = decodedGoals
                        }
                    } else {
                        print("Error: 'goals' key is not returning a valid array")
                    }
                } else {
                    print("Error: API did not return valid JSON")
                }
            } catch {
                print("Error decoding goals:", error)
            }
        }.resume()
    }
    
    // Create Goal API Call
    func createGoal() {
        guard let url = URL(string: "\(apiBaseUrl)/create") else { return }
        
        let goalData: [String: Any] = [
            "email": userEmail,
            "title": newGoalTitle,
            "description": "",
            "tasks": goaltasks.map { $0.name }
        ]
        
        print("📤 Creating Goal with Data:", goalData)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: goalData) else {
            print("❌ JSON Serialization failed for createGoal()")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error creating goal:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📩 Create Goal Response Code:", httpResponse.statusCode)
            }
            
            if let data = data {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✅ Create Goal Response:", responseJSON)
                    DispatchQueue.main.async {
                        fetchGoals() // Refresh after creating a goal
                        newGoalTitle = ""
                        goaltasks.removeAll()
                    }
                } catch {
                    print("❌ Error decoding create goal response:", error)
                }
            }
        }.resume()
    }
    
    
    // Mark Task as Completed
    func markTaskComplete(goalIndex: Int, taskIndex: Int) {
        guard let url = URL(string: "\(apiBaseUrl)/update") else { return }
        
        let requestData: [String: Any] = [
            "email": userEmail,
            "goalIndex": goalIndex,
            "taskIndex": taskIndex
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async {
                        fetchGoals()  // Refresh after marking a task complete
                    }
                } catch {
                    print("Error updating task:", error)
                }
            }
        }.resume()
    }
    
    // Delete Goal
    func deleteGoal(goalId: String) {
        guard let url = URL(string: "\(apiBaseUrl)/delete") else { return }
        
        let requestData: [String: Any] = [
            "email": userEmail,
            "goalId": goalId  // ✅ Send goalId instead of goalIndex
        ]
        
        print("📤 Deleting Goal:", requestData)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData) else {
            print("❌ JSON Serialization failed for deleteGoal()")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error deleting goal:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📩 Delete Goal Response Code:", httpResponse.statusCode)
            }
            
            if let data = data {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✅ Delete Goal Response:", responseJSON)
                    DispatchQueue.main.async {
                        fetchGoals()  // Refresh UI after deleting a goal
                    }
                } catch {
                    print("❌ Error decoding delete goal response:", error)
                }
            }
        }.resume()
    }
}


#Preview {
    GoalsView()
}
