//
//  BrokerageOnboardingView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI

struct BrokerageOnboardingView: View {
    @StateObject private var viewModel = BrokerageOnboardingViewModel()
    @State private var textAnswer: String = ""
    @State private var birthday: Date = Date()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ProgressView(value: Double(viewModel.currentQuestionIndex + 1) / Double(viewModel.questions.count))
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Spacer()

            Text(viewModel.questions[viewModel.currentQuestionIndex].text)
                .font(.system(size: 24))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            switch viewModel.questions[viewModel.currentQuestionIndex].type {
            case .text:
                if viewModel.questions[viewModel.currentQuestionIndex].text == "Date of Birth" {
                    DatePicker(" ", selection: $birthday, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .onChange(of: birthday) { newDate in
                            viewModel.birthday = newDate
                        }
                        .padding()
                } else {
                    TextField("Enter your answer", text: $textAnswer)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                        .padding()
                }

            case .singleSelect(let options):
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        viewModel.selectedAnswers = [option]
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedAnswers.contains(option) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(colorScheme == .dark ? .white : (viewModel.selectedAnswers.contains(option) ? .white : .black))
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 4)
                }

            case .multiSelect(let options):
                ForEach(options, id: \.self) { option in
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
                            .foregroundColor(colorScheme == .dark ? .white : (viewModel.selectedAnswers.contains(option) ? .white : .black))
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 4)
                }

            case .link(let url):
                Link("View Agreement", destination: URL(string: url)!)
                    .foregroundColor(.blue)
                    .padding()
            }

            Spacer()

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
        .alert(isPresented: $viewModel.showAgeRestrictionAlert) {
            Alert(title: Text("Age Restriction"), message: Text("You must be 18 or older to continue."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $viewModel.showEligibilityRestrictionAlert) {
            Alert(title: Text("Eligibility Restriction"), message: Text("You must be a US Citizen or Permanent Resident to continue."), dismissButton: .default(Text("OK")))
        }
    }
}





#Preview {
    BrokerageOnboardingView()
}
