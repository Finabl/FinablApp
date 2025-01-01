//
//  OnboardingView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/23/24.
//

import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @StateObject private var viewModel = QuestionViewModel()
    @State private var textAnswer: String = ""
    @State private var birthday: Date = Date() // For capturing birthday

    var body: some View {
        VStack(spacing: 16) {
            // Progress Bar with Elephant Icon
            ZStack(alignment: .leading) {
                ProgressView(value: Double(viewModel.currentQuestionIndex) / Double(viewModel.questions.count - 1))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

                GeometryReader { geometry in
                    Image("elephant head")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .offset(x: CGFloat(viewModel.currentQuestionIndex) / CGFloat(viewModel.questions.count - 1) * (geometry.size.width - 50))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)
                        .zIndex(1)
                }
                .frame(height: 50)
            }
            .frame(height: 60)
            .padding(.vertical, 10)

            Spacer()

            // Question Text
            Text(viewModel.currentQuestion.text)
                .font(Font.custom("Anuphan-Medium", size: 24))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

            // Dynamic Subtitle
            switch viewModel.currentQuestion.type {
            case .singleSelect, .multiSelect:
                Text("Select one from the following")
                    .font(Font.custom("Anuphan-Regular", size: 16))
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            default:
                EmptyView()
            }

            // Dynamic Content Based on Question Type
            ScrollView {
                VStack(spacing: 10) {
                    switch viewModel.currentQuestion.type {
                    case .text:
                        if viewModel.currentQuestion.text == "When is your birthday?" {
                            DatePicker(" ", selection: $birthday, displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .onChange(of: birthday) { newDate in
                                    viewModel.birthday = newDate // Update birthday in ViewModel
                                }
                                .padding()
                        } else {
                            TextField("Enter your answer", text: $textAnswer)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                                .padding()
                                .onChange(of: textAnswer) { newText in
                                    viewModel.captureAnswer(for: viewModel.currentQuestion.text, value: newText)
                                }
                        }

                    case .singleSelect(let options):
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                viewModel.captureAnswer(for: viewModel.currentQuestion.text, value: option)
                            }) {
                                Text(option)
                                    .multilineTextAlignment(.leading)
                                    .font(Font.custom("Anuphan-Medium", size: 18))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(viewModel.selectedAnswers.contains(option) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(
                                        viewModel.selectedAnswers.contains(option) ? .white : .black
                                    )
                                    .cornerRadius(10)
                            }
                            .padding(.vertical, 4)
                        }

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
                    viewModel.goToPreviousQuestion()
                    textAnswer = ""
                }
                .font(Font.custom("Anuphan-Medium", size: 16))
                .disabled(viewModel.currentQuestionIndex == 0)
                .padding()

                Spacer()

                if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
                    // Submit Button for Last Question
                    Button("Submit") {
                        viewModel.submitAnswers { success in
                            if success {
                                print("Signup successful!")
                            } else {
                                print("Signup failed.")
                            }
                        }
                    }
                    .font(Font.custom("Anuphan-Medium", size: 16))
                    .padding()
                } else {
                    // Continue Button for Other Questions
                    Button("Continue") {
                        viewModel.goToNextQuestion()
                        textAnswer = ""
                    }
                    .font(Font.custom("Anuphan-Medium", size: 16))
                    .disabled(viewModel.selectedAnswers.isEmpty && viewModel.currentQuestion.type != .text)
                    .padding()
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: viewModel.currentQuestionIndex)
        .alert(isPresented: $viewModel.showAgeRestrictionAlert) {
            Alert(
                title: Text("Age Restriction"),
                message: Text("Finabl is only for users 13 and older."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    OnboardingView()
}
