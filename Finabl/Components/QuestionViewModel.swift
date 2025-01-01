//
//  QuestionViewModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI
import FirebaseAuth

// Define the QuestionType enum
enum QuestionType: Equatable {
    case text
    case singleSelect(options: [String])
    case multiSelect(options: [String])

    static func == (lhs: QuestionType, rhs: QuestionType) -> Bool {
        switch (lhs, rhs) {
        case (.text, .text):
            return true
        case let (.singleSelect(lhsOptions), .singleSelect(rhsOptions)):
            return lhsOptions == rhsOptions
        case let (.multiSelect(lhsOptions), .multiSelect(rhsOptions)):
            return lhsOptions == rhsOptions
        default:
            return false
        }
    }
}

class QuestionViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = [] // Store single/multi-select answers
    @Published var showAgeRestrictionAlert: Bool = false
    @Published var birthday: Date? // Track the user's birthday to enforce age restriction.
    @Published var answers: [String: Any] = [:] // Store all collected answers

    let questions: [(text: String, type: QuestionType)] = [
        ("What is your first name?", .text),
        ("What is your last name?", .text),
        ("When is your birthday?", .text),
        ("What is your email address?", .text),
        ("What is your phone number?", .text),
        ("Are you currently a student?", .singleSelect(options: ["Yes", "No"])),
        ("What university do you attend?", .text),
        ("Create a user name", .text),
        ("Create a password", .text)
    ]

    var progress: Double {
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var currentQuestion: (text: String, type: QuestionType) {
        return questions[currentQuestionIndex]
    }

    func goToNextQuestion() {
        if currentQuestion.text == "Are you currently a student?" && selectedAnswers.first == "No" {
            currentQuestionIndex += 2 // Skip "What university do you attend?"
            selectedAnswers = []
            return
        }

        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswers = []
        }
    }

    func goToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            selectedAnswers = []
        }
    }

    func captureAnswer(for question: String, value: Any) {
        // Check if the current question type is `singleSelect`
        if case let QuestionType.singleSelect(options) = questions[currentQuestionIndex].type {
            // Ensure the selected value is a valid option
            if let selectedValue = value as? String, options.contains(selectedValue) {
                selectedAnswers = [selectedValue] // Update selected answer
            }
        } else {
            // For text input and other types, directly update the answers
            answers[question] = value
        }
    }


    func submitAnswers(completion: @escaping (Bool) -> Void) {
        guard let email = answers["What is your email address?"] as? String,
              let rawPassword = answers["Create a password"] as? String else {
            print("Email or password missing")
            completion(false)
            return
        }

        let password = rawPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        if password.count < 6 {
            print("Password must be at least 6 characters")
            completion(false)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Firebase user creation failed: \(error.localizedDescription)")
                completion(false)
                return
            }

            print("Firebase user created successfully")

            let apiData: [String: Any] = [
                "firstName": self.answers["What is your first name?"] ?? "",
                "lastName": self.answers["What is your last name?"] ?? "",
                "birthday": self.birthday?.iso8601String() ?? "",
                "email": email,
                "phoneNumber": self.answers["What is your phone number?"] ?? "",
                "isStudent": self.answers["Are you currently a student?"] as? String == "Yes",
                "university": self.answers["What university do you attend?"] ?? "",
                "userName": self.answers["Create a user name"] ?? ""
            ]

            self.postAnswersToAPI(apiData: apiData, completion: completion)
        }
    }

    private func postAnswersToAPI(apiData: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:3000/api/users/register") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: apiData, options: [])
        } catch {
            print("Error serializing API data: \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API request failed: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("API response status code invalid")
                completion(false)
                return
            }

            print("User registered successfully via API")
            completion(true)
        }.resume()
    }
}

extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
