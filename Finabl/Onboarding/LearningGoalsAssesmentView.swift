//
//  LearningGoalsAssessmentView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI
import FirebaseAuth

struct LearningGoalsAssessmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = LearningGoalsAssessmentViewModel()
    @State private var textAnswer: String = ""
    @State private var isSubmissionSuccessful: Bool = false // Tracks if submission is successful

    var body: some View {
        VStack(spacing: 16) {
            if isSubmissionSuccessful {
                // Completion Screen
                VStack {
                    Text("Learning Goals Assessment Completed!")
                        .font(Font.custom("Anuphan-Medium", size: 24))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Progress Bar with Moving Logo
                ZStack(alignment: .leading) {
                    // Progress Bar
                    ProgressView(value: Double(viewModel.currentQuestionIndex) / Double(viewModel.questions.count - 1))
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

                    // Moving Logo
                    GeometryReader { geometry in
                        Image("elephant head") // Replace with your logo
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                            .offset(x: CGFloat(viewModel.currentQuestionIndex) / CGFloat(viewModel.questions.count - 1) * (geometry.size.width - 50)) // Start at 0
                            .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)
                            .zIndex(1) // Ensure the logo appears above the bar
                    }
                    .frame(height: 50)
                }
                .frame(height: 60)
                .padding(.vertical, 10)

                Spacer()

                // Question Text
                Text(viewModel.questions[viewModel.currentQuestionIndex].text)
                    .font(Font.custom("Anuphan-Medium", size: 24))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Dynamic Subtitle
                Text(subtitleForQuestionType(viewModel.questions[viewModel.currentQuestionIndex].type))
                    .font(Font.custom("Anuphan-Regular", size: 16))
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)

                ScrollView {
                    VStack(spacing: 10) {
                        switch viewModel.questions[viewModel.currentQuestionIndex].type {
                        case .singleSelect(let options):
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    viewModel.selectedAnswers = [option]
                                }) {
                                    Text(option)
                                        .multilineTextAlignment(.leading)
                                        .font(Font.custom("Anuphan-Medium", size: 18))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(viewModel.selectedAnswers.contains(option) ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(
                                            colorScheme == .dark
                                                ? .white
                                                : (viewModel.selectedAnswers.contains(option) ? .white : .black)
                                        )
                                        .cornerRadius(10)
                                }
                                .padding(.vertical, 4)
                            }

                        case .multiSelect(let options):
                            ForEach(options, id: \.self) { option in
                                if option == "Other (please specify)" {
                                    VStack {
                                        TextField("Please specify", text: $viewModel.customAnswer)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                                    }
                                    .padding(.vertical, 4)
                                } else {
                                    Button(action: {
                                        if viewModel.selectedAnswers.contains(option) {
                                            viewModel.selectedAnswers.removeAll { $0 == option }
                                        } else {
                                            viewModel.selectedAnswers.append(option)
                                        }
                                    }) {
                                        Text(option)
                                            .font(Font.custom("Anuphan-Medium", size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(viewModel.selectedAnswers.contains(option) ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(
                                                colorScheme == .dark
                                                    ? .white
                                                    : (viewModel.selectedAnswers.contains(option) ? .white : .black)
                                            )
                                            .cornerRadius(10)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }

                        case .text:
                            TextField("Enter your answer", text: $textAnswer)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                                .padding()
                        }
                    }
                    .padding(.vertical, 5)
                }
            }

            Spacer()

            // Navigation Buttons
            HStack {
                Button("Back") {
                    withAnimation {
                        viewModel.goToPreviousQuestion()
                        textAnswer = ""
                    }
                }
                .disabled(viewModel.currentQuestionIndex == 0)
                .padding()

                Spacer()

                if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
                    // Submit Button for Last Question
                    Button("Submit") {
                        if case .text = viewModel.questions[viewModel.currentQuestionIndex].type {
                            viewModel.selectedAnswers = [textAnswer]
                        }
                        viewModel.submitAnswers { success in
                            if success {
                                DispatchQueue.main.async {
                                    isSubmissionSuccessful = true
                                }
                            }
                        }
                    }
                    .disabled(viewModel.selectedAnswers.isEmpty && viewModel.questions[viewModel.currentQuestionIndex].type != .text)
                    .padding()
                } else {
                    // Continue Button for Other Questions
                    Button("Continue") {
                        if case .text = viewModel.questions[viewModel.currentQuestionIndex].type {
                            viewModel.selectedAnswers = [textAnswer]
                        }
                        viewModel.goToNextQuestion()
                        textAnswer = ""
                    }
                    .disabled(viewModel.selectedAnswers.isEmpty && viewModel.questions[viewModel.currentQuestionIndex].type != .text)
                    .padding()
                }
            }
        }
        .padding()
    }

    // Helper function for subtitle text
    private func subtitleForQuestionType(_ type: LearningAssessmentQuestionType) -> String {
        switch type {
        case .singleSelect:
            return "Select one from the following"
        case .multiSelect:
            return "Select one or more from the following"
        case .text:
            return "Provide your response below"
        }
    }
}

#Preview {
    LearningGoalsAssessmentView()
}
