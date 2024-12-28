//
//  LearningGoalsAssesmentModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import Foundation

enum LearningAssessmentQuestionType: Equatable {
    case singleSelect(options: [String])
    case multiSelect(options: [String])
    case text
}

class LearningGoalsAssessmentViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = []
    @Published var customAnswer: String = ""
    
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
}
