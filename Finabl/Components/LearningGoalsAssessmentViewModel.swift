//
//  LearningGoalsAssessmentViewModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import Foundation
import FirebaseAuth

enum LearningAssessmentQuestionType: Equatable {
    case singleSelect(options: [String])
    case multiSelect(options: [String])
    case text
}

class LearningGoalsAssessmentViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = []
    @Published var customAnswer: String = ""
    @Published var answersSummary: [String: [String]] = [:] // To store answers for each question

    var questions: [(text: String, type: LearningAssessmentQuestionType)] = [
        (
            "How would you rate your current investment knowledge?",
            .singleSelect(options: [
                "Beginner: I have little to no knowledge about investing.",
                "Intermediate: I understand basic concepts but need guidance.",
                "Advanced: I am comfortable with investing concepts and strategies."
            ])
        ),
        (
            "What investment topics are you most interested in learning about?",
            .multiSelect(options: [
                "Basics of stock investing",
                "Cryptocurrency and digital assets",
                "Sustainable investing (ESG)",
                "Portfolio diversification",
                "Risk management",
                "Advanced trading strategies",
                "Options",
                "I want to learn as much as I can!",
                "Other (please specify)"
            ])
        ),
        (
            "What learning format do you prefer?",
            .multiSelect(options: [
                "Interactive lessons",
                "Short videos and animations",
                "Quizzes and assessments",
                "Real-life case studies",
                "Step-by-step tutorials",
                "Articles and reading material"
            ])
        ),
        (
            "How much time are you willing to dedicate daily to learning about investing?",
            .singleSelect(options: [
                "10 minutes",
                "20 minutes",
                "30 minutes",
                "45 minutes",
                "1 hour+"
            ])
        ),
        (
            "What’s your main learning objective?",
            .singleSelect(options: [
                "Understanding the basics of investing",
                "Building a strong investment strategy",
                "Gaining knowledge for career purposes",
                "Enhancing my decision-making skills as an investor",
                "Other (please specify)"
            ])
        )
    ]

    var progress: Double {
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    func goToNextQuestion() {
        saveCurrentAnswer()
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswers = []
            customAnswer = ""
        }
    }

    func goToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            selectedAnswers = []
            customAnswer = ""
        }
    }

    func saveCurrentAnswer() {
        let currentQuestion = questions[currentQuestionIndex].text
        if !customAnswer.isEmpty {
            answersSummary[currentQuestion] = [customAnswer]
        } else {
            answersSummary[currentQuestion] = selectedAnswers
        }
    }

    func submitAnswers(completion: @escaping (Bool) -> Void) {
        saveCurrentAnswer() // Save the last answer
        guard let email = Auth.auth().currentUser?.email else {
            print("User not logged in")
            completion(false)
            return
        }

        let urlString = "http://127.0.0.1:3000/api/users/user/\(email)/add"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        // Compile JSON in the required format
        let json: [String: Any] = [
            "learningGoals": [
                "current_knowledge": answersSummary["How would you rate your current investment knowledge?"]?.first ?? "",
                "interests": answersSummary["What investment topics are you most interested in learning about?"] ?? [],
                "preferred_formats": answersSummary["What learning format do you prefer?"] ?? [],
                "daily_time": answersSummary["How much time are you willing to dedicate daily to learning about investing?"]?.first ?? "",
                "learning_objective": answersSummary["What’s your main learning objective?"]?.first ?? ""
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error submitting data: \(error)")
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Learning goals submitted successfully")
                    completion(true)
                } else {
                    print("Failed to submit learning goals")
                    completion(false)
                }
            }
            task.resume()
        } catch {
            print("Error serializing JSON: \(error)")
            completion(false)
        }
    }

    
}
