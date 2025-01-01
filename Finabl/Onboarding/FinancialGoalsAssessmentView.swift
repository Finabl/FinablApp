//
//  FinancialGoalsAssessmentView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI
import FirebaseAuth

struct FinancialGoalsAssessmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = FinancialGoalsAssessmentViewModel()
    @State private var textAnswer: String = ""
    @State private var isSubmissionSuccessful: Bool = false // Tracks submission success

    var body: some View {
        VStack(spacing: 16) {
            if isSubmissionSuccessful {
                // Success Screen
                Text("Financial Goals Assessment Completed!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                // Progress Bar
                ZStack(alignment: .leading) {
                    ProgressView(value: Double(viewModel.currentQuestionIndex) / Double(viewModel.questions.count - 1))
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

                    // Moving Logo
                    GeometryReader { geometry in
                        Image("elephant head")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                            .offset(x: CGFloat(viewModel.currentQuestionIndex) / CGFloat(viewModel.questions.count - 1) * (geometry.size.width - 50))
                            .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)
                            .zIndex(1) // Ensure logo appears above the bar
                    }
                    .frame(height: 50)
                }
                .frame(height: 60)
                .padding(.vertical, 10)

                Spacer()

                // Question Title
                Text(viewModel.questions[viewModel.currentQuestionIndex].text)
                    .font(Font.custom("Anuphan-Medium", size: 24))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

                // Dynamic Subtitle
                if viewModel.questions[viewModel.currentQuestionIndex].type == .singleSelect(options: []) ||
                    viewModel.questions[viewModel.currentQuestionIndex].type == .multiSelect(options: []) {
                    Text("Select one or more from the following")
                        .font(Font.custom("Anuphan-Regular", size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }

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
                                if option == "Other" || option == "Other (please specify)" {
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
                            VStack {
                                TextField("Enter your answer", text: $textAnswer)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 1)
                                            .background(Color.white.cornerRadius(10))
                                    )
                                    .padding()
                            }
                            .frame(maxHeight: .infinity, alignment: .top)

                        default:
                            EmptyView()
                        }
                    }
                    .padding(.vertical, 5)
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
                    .font(Font.custom("Anuphan-Medium", size: 16))
                    .disabled(viewModel.currentQuestionIndex == 0)
                    .padding()

                    Spacer()

                    if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
                        // Submit Button on Last Question
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
                        .font(Font.custom("Anuphan-Medium", size: 16))
                        .disabled(viewModel.selectedAnswers.isEmpty && viewModel.questions[viewModel.currentQuestionIndex].type != .text)
                        .padding()
                    } else {
                        // Continue Button for Other Questions
                        Button("Continue") {
                            withAnimation {
                                if case .text = viewModel.questions[viewModel.currentQuestionIndex].type {
                                    viewModel.selectedAnswers = [textAnswer]
                                }
                                viewModel.goToNextQuestion()
                                textAnswer = ""
                            }
                        }
                        .font(Font.custom("Anuphan-Medium", size: 16))
                        .disabled(viewModel.selectedAnswers.isEmpty && viewModel.questions[viewModel.currentQuestionIndex].type != .text)
                        .padding()
                    }
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: viewModel.currentQuestionIndex)
    }
}

#Preview {
    FinancialGoalsAssessmentView()
}
