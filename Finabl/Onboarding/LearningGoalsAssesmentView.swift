//
//  LearningGoalsAssesmentView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI

struct LearningGoalsAssessmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = LearningGoalsAssessmentViewModel()
    @State private var textAnswer: String = ""

    var body: some View {
        VStack {
            // Progress Bar
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Spacer()

            // Question Text
            Text(viewModel.questions[viewModel.currentQuestionIndex].text)
                .font(.system(size: 24))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            // Dynamic Content Based on Question Type
            switch viewModel.questions[viewModel.currentQuestionIndex].type {
            case .singleSelect(let options):
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        viewModel.selectedAnswers = [option]
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
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
                                .frame(maxWidth: .infinity)
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

            Spacer()

            // Navigation Buttons
            HStack {
                Button("Back") {
                    viewModel.goToPreviousQuestion()
                    textAnswer = ""
                }
                .disabled(viewModel.currentQuestionIndex == 0)
                .padding()

                Spacer()

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
        .padding()
    }
}


#Preview {
    LearningGoalsAssessmentView()
}
