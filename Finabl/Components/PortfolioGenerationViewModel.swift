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

class PortfolioGenerationViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = []
    @Published var customAnswer: String = ""
    @Published var answersSummary: [String: [String]] = [:] // Store answers for each question
    @Published var isCompleted: Bool = false // Tracks whether the questionnaire is complete

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
}
