//
//  FirstName.swift
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
        VStack {
            // Progress Bar
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Spacer()

            // Question Text
            Text(viewModel.currentQuestion.text)
                .font(.system(size: 32))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Dynamic Content Based on Question Type
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
                    HStack {
                        TextField("Enter your answer", text: $textAnswer)
                            .padding()
                            .onChange(of: textAnswer) { newText in
                                viewModel.captureAnswer(for: viewModel.currentQuestion.text, value: newText)
                            }
                    }
                    .cornerRadius(10)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 0.5))
                }

            case .singleSelect(let options):
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        viewModel.captureAnswer(for: viewModel.currentQuestion.text, value: option)
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedAnswers.contains(option) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.selectedAnswers.contains(option) ? Color.white : Color.black)
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 4)
                }

            default:
                EmptyView()
            }

            Spacer()

            // Navigation Buttons
            HStack {
                Button(action: {
                    viewModel.goToPreviousQuestion()
                    textAnswer = ""
                }) {
                    Text("Back")
                }
                .disabled(viewModel.currentQuestionIndex == 0)
                .padding()

                Spacer()

                if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
                    Button(action: {
                        viewModel.submitAnswers { success in
                            if success {
                                print("Signup successful!")
                            } else {
                                print("Signup failed.")
                            }
                        }
                    }) {
                        Text("Submit")
                    }
                    .padding()
                } else {
                    Button(action: {
                        viewModel.goToNextQuestion()
                        textAnswer = ""
                    }) {
                        Text("Continue")
                    }
                    .disabled(viewModel.selectedAnswers.isEmpty && viewModel.currentQuestion.type != .text)
                    .padding()
                }
            }
            .padding(.horizontal)
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
