//
//  FinancialGoalsViewModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import Foundation
import FirebaseAuth

enum FinancialGoalsQuestionType: Equatable {
    case singleSelect(options: [String])
    case multiSelect(options: [String])
    case text
}

class FinancialGoalsAssessmentViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = []
    @Published var customAnswer: String = ""
    @Published var answersSummary: [String: [String]] = [:] // Store all answers

    var questions: [(text: String, type: FinancialGoalsQuestionType)] = [
        (
            "What is your primary reason for investing?",
            .multiSelect(options: [
                "Wealth accumulation",
                "Saving for retirement",
                "Saving for a major purchase",
                "Education Expenses",
                "Medical expenses",
                "Other"
            ])
        ),
        (
            "How long do you intend to keep your investment portfolios?",
            .singleSelect(options: [
                "Less than 1 year",
                "1-3 years",
                "3-5 years",
                "5-10 years",
                "10+ years"
            ])
        ),
        (
            "How would you describe your comfort level with risk? (percentage of typically risk assets: percentage of typically non-risk assets)",
            .singleSelect(options: [
                "Very Conservative: I want to preserve capital and avoid losses. (10:90)",
                "Conservative: I prefer minimal risk with small growth potential. (30:70)",
                "Moderate: I can tolerate some risk for moderate growth. (50:50)",
                "Aggressive: I am comfortable with high risk for higher returns. (70:30)",
                "Very Aggressive: I am willing to take high risks for maximum growth potential. (90:10)"
            ])
        ),
        (
            "Do you require regular income from your investments?",
            .singleSelect(options: [
                "Yes, monthly income",
                "Yes, quarterly income",
                "Yes, yearly income",
                "No, I do not need income; I want to reinvest earnings"
            ])
        ),
        (
            "Are there specific sectors, themes, or types of companies you’re interested in?",
            .multiSelect(options: [
                "Technology",
                "Environmental, Social, and Governance (ESG)",
                "Healthcare",
                "Real estate",
                "Cryptocurrency",
                "General diversification",
                "No specific preference",
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
        print(urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        // Compile JSON in the required format
        let json: [String: Any] = [
            "financialGoals": [
                "primary_reason": answersSummary["What is your primary reason for investing?"] ?? [],
                "time_horizon": answersSummary["How long do you intend to keep your investment portfolios?"] ?? [],
                "risk_tolerance": answersSummary["How would you describe your comfort level with risk? (percentage of typically risk assets: percentage of typically non-risk assets)"] ?? [],
                "income_required": answersSummary["Do you require regular income from your investments?"]?.first ?? "",
                "interest_sectors": answersSummary["Are there specific sectors, themes, or types of companies you’re interested in?"] ?? []
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
                    print("Financial goals submitted successfully")
                    completion(true)
                } else {
                    print("Failed to submit financial goals")
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
