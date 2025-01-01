//
//  PortfolioGenerationViewModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import Foundation
import SwiftUI

enum PortfolioQuestionType: Equatable {
    case singleSelect(options: [String])
    case multiSelect(options: [MultiSelectOption])
    case text
}

struct MultiSelectOption: Identifiable, Equatable {
    let id = UUID()
    let option: String
    let info: String?
}

struct UserProfile: Decodable {
    let firstName: String
    let lastName: String
    let financialGoals: FinancialGoals
    let learningGoals: LearningGoals
}

struct FinancialGoals: Decodable {
    let time_horizon: [String]
    let risk_tolerance: [String]
}

struct LearningGoals: Decodable {
    let current_knowledge: String
}

class PortfolioGenerationViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = []
    @Published var customAnswer: String = ""
    @Published var answersSummary: [String: [String]] = [:] // Store answers for each question
    @Published var isCompleted: Bool = false // Tracks whether the questionnaire is complete

    @Published var userProfile: UserProfile? // Store user profile data

    var questions: [(text: String, type: PortfolioQuestionType)] = [
        (
            "Which type(s) of investing are you most interested in learning right now?",
            .multiSelect(options: [
                MultiSelectOption(option: "Thematic Investing", info: "Offers a narrative-driven way to invest based on interests or beliefs."),
                MultiSelectOption(option: "Passive Investing (Index Funds or ETFs)", info: "Low-maintenance, ideal for beginners."),
                MultiSelectOption(option: "Swing Trading", info: "Focuses on short-term trading strategies."),
                MultiSelectOption(option: "Long-Term Value Investing", info: "Builds wealth steadily over time."),
                MultiSelectOption(option: "Cryptocurrency Trading", info: "Involves trading popular cryptocurrencies."),
                MultiSelectOption(option: "Options Trading", info: "Advanced strategies for hedging or leveraging."),
                MultiSelectOption(option: "Impact Investing", info: "Focuses on aligning investments with ESG values.")
            ])
        ),
        (
            "Which type(s) of investing are you most familiar with and are interested in investing right now?",
            .multiSelect(options: [
                MultiSelectOption(option: "Thematic Investing", info: "Offers a narrative-driven way to invest based on interests or beliefs."),
                MultiSelectOption(option: "Passive Investing (Index Funds or ETFs)", info: "Low-maintenance, ideal for beginners."),
                MultiSelectOption(option: "Swing Trading", info: "Focuses on short-term trading strategies."),
                MultiSelectOption(option: "Long-Term Value Investing", info: "Builds wealth steadily over time."),
                MultiSelectOption(option: "Cryptocurrency Trading", info: "Involves trading popular cryptocurrencies."),
                MultiSelectOption(option: "Options Trading", info: "Advanced strategies for hedging or leveraging."),
                MultiSelectOption(option: "Impact Investing", info: "Focuses on aligning investments with ESG values.")
            ])
        ),
        (
            "How much are you looking to invest initially?",
            .singleSelect(options: [
                "Under $100",
                "$100-$1000",
                "$1000-$5000",
                "$5000-$10K",
                "$10K+"
            ])
        ),
        (
            "How often do you plan to invest additional funds into your portfolio?",
            .singleSelect(options: [
                "Monthly",
                "Quarterly",
                "Annually",
                "As funds are available, no set schedule"
            ])
        ),
        (
            "Are there specific sectors or industries you want to prioritize in your portfolio?",
            .multiSelect(options: [
                MultiSelectOption(option: "Technology", info: nil),
                MultiSelectOption(option: "Healthcare", info: nil),
                MultiSelectOption(option: "Real Estate", info: nil),
                MultiSelectOption(option: "Consumer Goods", info: nil),
                MultiSelectOption(option: "Renewable Energy", info: nil),
                MultiSelectOption(option: "Finance", info: nil),
                MultiSelectOption(option: "Infrastructure", info: nil),
                MultiSelectOption(option: "No specific preference", info: nil),
                MultiSelectOption(option: "Other (please specify)", info: "Enter custom preferences.")
            ])
        ),
        (
            "Would you prioritize higher returns at the expense of higher risk, or prefer lower, steadier returns?",
            .singleSelect(options: [
                "High-risk, high-return",
                "Balanced risk and return",
                "Low-risk, steady return"
            ])
        ),
        (
            "Do you have a preference for dividend-paying stocks?",
            .singleSelect(options: ["Yes", "No"])
        ),
        (
            "Do you have a preference for geographic exposure in your portfolio?",
            .singleSelect(options: [
                "U.S. only",
                "International markets",
                "Global diversification",
                "Other (please specify)"
            ])
        ),
        (
            "Are there specific investment themes that interest you?",
            .multiSelect(options: [
                MultiSelectOption(option: "Artificial Intelligence and Tech Innovation", info: nil),
                MultiSelectOption(option: "Clean Energy and Climate Change", info: nil),
                MultiSelectOption(option: "Health and Biotechnology", info: nil),
                MultiSelectOption(option: "Real Estate and Infrastructure", info: nil),
                MultiSelectOption(option: "Consumer Goods and Lifestyle Trends", info: nil),
                MultiSelectOption(option: "Defense and Aerospace", info: nil),
                MultiSelectOption(option: "General diversification across all themes", info: nil)
            ])
        ),
        (
            "How personalized would you like your portfolio to be?",
            .singleSelect(options: [
                "Highly unique to my preferences",
                "Balanced with market standards",
                "No preference; I want the best-performing portfolio regardless"
            ])
        )
    ]

    var progress: Double {
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    // Fetch user profile from the API
    func fetchUserProfile(email: String, completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:3000/api/users/user/\(email)") else {
            completion(NSError(domain: "InvalidURL", code: 400, userInfo: nil))
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user profile: \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                print("No data received from API.")
                completion(NSError(domain: "NoData", code: 400, userInfo: nil))
                return
            }

            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    print("Fetched user profile: \(userProfile)") // Debug log
                    self.userProfile = userProfile
                }
                completion(nil)
            } catch {
                print("Error decoding user profile: \(error)")
                completion(error)
            }
        }.resume()
    }

    func saveCurrentAnswer() {
        let currentQuestion = questions[currentQuestionIndex].text
        if !customAnswer.isEmpty {
            answersSummary[currentQuestion] = [customAnswer]
        } else {
            answersSummary[currentQuestion] = selectedAnswers
        }
    }

    func goToNextQuestion() {
        saveCurrentAnswer() // Save answers before moving forward
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswers = []
            customAnswer = ""
        } else {
            isCompleted = true // Mark as completed
        }
    }

    func goToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            selectedAnswers = []
            customAnswer = ""
        }
    }

    // Compile answers with user profile data
    func compileAnswersToJSON(email: String, completion: @escaping ([String: Any]?) -> Void) {
        // Fetch the user profile before compiling
        fetchUserProfile(email: email) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user profile: \(error)")
                completion(nil) // Return nil in case of an error
                return
            }
            
            DispatchQueue.main.async {
                // Ensure the user profile is not nil
                guard let userProfile = self.userProfile else {
                    print("User profile is still nil after fetching.")
                    completion(nil)
                    return
                }
                
                // Compile the JSON using the fetched user profile
                let timeHorizon = userProfile.financialGoals.time_horizon
                let riskTolerance = userProfile.financialGoals.risk_tolerance
                let investmentKnowledge = userProfile.learningGoals.current_knowledge
                
                let compiledJSON: [String: Any] = [
                    "time_horizon": timeHorizon,
                    "risk_tolerance": riskTolerance,
                    "investment_knowledge": investmentKnowledge,
                    "investment_interests_learning": self.answersSummary["Which type(s) of investing are you most interested in learning right now?"] ?? [],
                    "investment_interests_investing": self.answersSummary["Which type(s) of investing are you most familiar with and are interested in investing right now?"] ?? [],
                    "initial_investment": self.answersSummary["How much are you looking to invest initially?"]?.first ?? "",
                    "contribution_frequency": self.answersSummary["How often do you plan to invest additional funds into your portfolio?"]?.first ?? "",
                    "dividend_preference": self.answersSummary["Do you have a preference for dividend-paying stocks?"]?.first ?? "",
                    "geographic_exposure": self.answersSummary["Do you have a preference for geographic exposure in your portfolio?"]?.first ?? "",
                    "investment_themes": self.answersSummary["Are there specific investment themes that interest you?"] ?? [],
                    "personalization_level": self.answersSummary["How personalized would you like your portfolio to be?"]?.first ?? ""
                ]
                
                print("Compiled JSON: \(compiledJSON)")
                completion(compiledJSON) // Pass the compiled JSON to the completion handler
            }
        }
    }



    // Submit answers to the API
    func submitAnswersToAPI(compiledJSON: [String: Any], onPortfolioReceived: @escaping ([String: Any]) -> Void, completion: @escaping () -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/generate-portfolios") else {
            print("Invalid URL for portfolio submission.")
            completion()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: compiledJSON, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            completion()
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting portfolio data: \(error)")
                completion()
                return
            }

            guard let data = data else {
                print("No data received in response.")
                completion()
                return
            }

            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let portfolios = responseJSON["portfolios"] as? [[String: Any]] {
                    for portfolio in portfolios {
                        DispatchQueue.main.async {
                            onPortfolioReceived(portfolio) // Append portfolio as it arrives
                        }
                    }
                    DispatchQueue.main.async {
                        completion() // Signal completion
                    }
                } else {
                    print("Response JSON is not in expected format.")
                    completion()
                }
            } catch {
                print("Error decoding response: \(error)")
                completion()
            }
        }.resume()
    }






}
