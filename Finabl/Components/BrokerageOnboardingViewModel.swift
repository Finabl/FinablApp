//
//  BrokerageOnboardingViewModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import Foundation
import SwiftUI

enum BrokerageQuestionType: Equatable {
    case text
    case singleSelect(options: [String])
    case multiSelect(options: [String])
    case link(url: String)
}
enum ActiveAlert: Identifiable {
    case ageRestriction
    case eligibilityRestriction

    var id: Int {
        hashValue
    }
}


class BrokerageOnboardingViewModel: ObservableObject {
    @Published var activeAlert: ActiveAlert?
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String] = []
    @Published var showAgeRestrictionAlert: Bool = false
    @Published var showEligibilityRestrictionAlert: Bool = false
    @Published var agreementsAccepted: Bool = false
    @Published var birthday: Date?
    //@Published var citizenshipQuestion: Int = 7
    
    
    
    var questions: [(text: String, type: BrokerageQuestionType)] = [
        ("What is your Legal First Name?", .text),
        ("What is your Legal Last Name?", .text),
        ("Date of Birth", .text),
        ("Street Address & Unit #", .text),
        ("City", .text),
        ("State", .text),
        ("Postal Code", .text),
        ("Are you a US Citizen?", .singleSelect(options: ["Yes", "No"])),
        ("If not, Are you a Permanent Resident?", .singleSelect(options: ["Yes", "No"])),
        ("Social Security Number / ITIN Number", .text),
        ("What are the sources of your investment funding?", .multiSelect(options: [
            "Employment Income", "Investments", "Inheritance", "Business Income", "Savings", "Family"
        ])),
        ("Do you hold a controlling position in a publicly traded company, are a member of the board of directors, or have policy-making abilities?", .singleSelect(options: ["Yes", "No"])),
        ("Are you affiliated with any exchanges or FINRA?", .singleSelect(options: ["Yes", "No"])),
        ("Are you politically exposed?", .singleSelect(options: ["Yes", "No"])),
        ("Are any of your immediate family members either politically exposed or hold a control position?", .singleSelect(options: ["Yes", "No"])),
        ("Accept Alpaca Margin Agreement", .singleSelect(options: ["Accept"])),
        ("Accept Alpaca Account Agreement", .singleSelect(options: ["Accept"]))
    ]

    let companyQuestions: [(text: String, type: BrokerageQuestionType)] = [
        ("Name of Company", .text),
        ("Company Street Address", .text),
        ("Company City", .text),
        ("Company State", .text),
        ("Company Country", .text),
        ("Do you have any more companies to add?", .singleSelect(options: ["Yes", "No"]))
    ]

    let politicallyExposedQuestions: [(text: String, type: BrokerageQuestionType)] = [
        ("Given Name of politically exposed person", .text),
        ("Last Name of politically exposed person", .text),
        ("Do you have any more people to add?", .singleSelect(options: ["Yes", "No"]))
    ]

    func goToNextQuestion() {
        
        // Handle Age Restriction
        if currentQuestionIndex == 2 {
            
            if birthday == nil { // Use the default date if not set
                birthday = Date()
            }
            
            guard let birthday = birthday else { return }
            if !isValidAge(birthday) {
                activeAlert = .ageRestriction
                return
            }
        }

        // Citizenship Restriction
        if currentQuestionIndex == 7 {
            if selectedAnswers.contains("Yes") {
                currentQuestionIndex += 1
            }
        }
        if currentQuestionIndex == 8 && selectedAnswers.contains("No") {
            activeAlert = .eligibilityRestriction
            return
        }

        // Handle Follow-Up Logic for Companies
        if questions[currentQuestionIndex].text == "Do you hold a controlling position in a publicly traded company, are a member of the board of directors, or have policy-making abilities?" {
            if selectedAnswers.contains("Yes") {
                questions.insert(contentsOf: companyQuestions, at: currentQuestionIndex + 1)
                if currentQuestionIndex < questions.count - 1 {
                    currentQuestionIndex += 1
                    selectedAnswers = []
                }
                return
            }
        }

        // Handle Politically Exposed Logic
        if questions[currentQuestionIndex].text == "Are you politically exposed?" || questions[currentQuestionIndex].text == "Are any of your immediate family members either politically exposed or hold a control position?" {
            if selectedAnswers.contains("Yes") {
                questions.insert(contentsOf: politicallyExposedQuestions, at: currentQuestionIndex + 1)
                if currentQuestionIndex < questions.count - 1 {
                    currentQuestionIndex += 1
                    selectedAnswers = []
                }
                return
            }
        }

        // Move to Next Question
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

    private func isValidAge(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let age = calendar.dateComponents([.year], from: date, to: now).year ?? 0

        // Optional: Add a check to ensure the user has interacted with the DatePicker
        if calendar.isDateInToday(date) {
            print("saur sad")
            return false // Require user interaction
        }

        return age >= 18
    }

}
