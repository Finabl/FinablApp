//
//  BrokerageOnboardingView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI

struct BrokerageOnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = BrokerageOnboardingViewModel()
    @State private var textAnswer: String = ""
    @State private var birthday: Date = Date()
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                VStack(spacing: 16) {
                    ZStack(alignment: .leading) {
                        // Progress Bar
                        ProgressView(value: Double(viewModel.currentQuestionIndex + 1) / Double(viewModel.questions.count))
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

                        // Moving Logo
                        GeometryReader { geometry in
                            Image("elephant head")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                                .offset(x: CGFloat(viewModel.currentQuestionIndex) / CGFloat(viewModel.questions.count) * (geometry.size.width - 50))
                                .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)
                                .zIndex(1)
                        }
                        .frame(height: 50)
                    }
                    .frame(height: 60)
                    .padding(.vertical, 10)

                    // Question Title
                    Text(viewModel.questions[viewModel.currentQuestionIndex].text)
                        .font(Font.custom("Anuphan-Medium", size: 24))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

                    ScrollView {
                        VStack(spacing: 10) {
                            switch viewModel.questions[viewModel.currentQuestionIndex].type {
                            case .text:
                                if viewModel.questions[viewModel.currentQuestionIndex].text == "Date of Birth" {
                                    DatePicker(" ", selection: Binding<Date>(
                                        get: { viewModel.birthday ?? Date() },
                                        set: { viewModel.birthday = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .padding()

                                } else {
                                    TextField("Enter your answer", text: $textAnswer)
                                        .disableAutocorrection(true)
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
                                    Button(action: {
                                        if viewModel.selectedAnswers.contains(option) {
                                            viewModel.selectedAnswers.removeAll { $0 == option }
                                        } else {
                                            viewModel.selectedAnswers.append(option)
                                        }
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

                            case .link(let url):
                                Link("View Agreement", destination: URL(string: url)!)
                                    .foregroundColor(.blue)
                                    .padding()

                            default:
                                EmptyView()
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                Spacer()

                HStack {
                    Button("Back") {
                        withAnimation {
                            viewModel.goToPreviousQuestion()
                        }
                    }
                    .font(Font.custom("Anuphan-Medium", size: 16))
                    .disabled(viewModel.currentQuestionIndex == 0)
                    .padding()

                    Spacer()

                    Button("Continue") {
                        withAnimation {
                            if case .text = viewModel.questions[viewModel.currentQuestionIndex].type {
                                viewModel.selectedAnswers = [textAnswer]
                            }
                            textAnswer = ""
                            viewModel.goToNextQuestion()
                        }
                    }
                    .font(Font.custom("Anuphan-Medium", size: 16))
                    .disabled(viewModel.selectedAnswers.isEmpty && viewModel.questions[viewModel.currentQuestionIndex].type != .text)
                    .padding()
                }
            }
            .padding()

            if isLoading {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ProgressView("Loading...")
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.primary)
                        .padding()
                    Text("Please wait...")
                        .font(Font.custom("Anuphan-Regular", size: 16))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.secondary)
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
        .alert(item: $viewModel.activeAlert) { alertType in
            switch alertType {
            case .ageRestriction:
                return Alert(
                    title: Text("Age Restriction"),
                    message: Text("You must be 18 or older to continue."),
                    dismissButton: .default(Text("OK"))
                )
            case .eligibilityRestriction:
                return Alert(
                    title: Text("Eligibility Restriction"),
                    message: Text("You must be a US Citizen or Permanent Resident to continue."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    BrokerageOnboardingView()
}
