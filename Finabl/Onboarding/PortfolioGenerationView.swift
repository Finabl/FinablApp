//
//  PortfolioGenerationView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct PortfolioGenerationView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = PortfolioGenerationViewModel()
    @State private var expandedInfo: String? = nil // Tracks which option's info box is expanded
    @State private var navigateToPortfolioDisplay: Bool = false // Tracks navigation to PortfolioDisplayView
    @StateObject private var displayViewModel = PortfolioDisplayViewModel()
    @State private var isLoading: Bool = false // Tracks if the loading screen is active
    let userEmail = Auth.auth().currentUser?.email

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                VStack(spacing: 16) {
                    ZStack(alignment: .leading) {
                        // Progress Bar
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

                    // Question Title
                    Text(viewModel.questions[viewModel.currentQuestionIndex].text)
                        .font(Font.custom("Anuphan-Medium", size: 24))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentQuestionIndex)

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
                            case .multiSelect(let optionsWithInfo):
                                ForEach(optionsWithInfo, id: \.option) { optionWithInfo in
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Button(action: {
                                                if viewModel.selectedAnswers.contains(optionWithInfo.option) {
                                                    viewModel.selectedAnswers.removeAll { $0 == optionWithInfo.option }
                                                } else {
                                                    viewModel.selectedAnswers.append(optionWithInfo.option)
                                                }
                                            }) {
                                                Text(optionWithInfo.option)
                                                    .font(Font.custom("Anuphan-Medium", size: 18))
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                                    .background(viewModel.selectedAnswers.contains(optionWithInfo.option) ? Color.blue : Color.gray.opacity(0.2))
                                                    .foregroundColor(
                                                        colorScheme == .dark
                                                            ? .white
                                                            : (viewModel.selectedAnswers.contains(optionWithInfo.option) ? .white : .black)
                                                    )
                                                    .cornerRadius(10)
                                            }

                                            if let info = optionWithInfo.info {
                                                Button(action: {
                                                    withAnimation {
                                                        if expandedInfo == info {
                                                            expandedInfo = nil
                                                        } else {
                                                            expandedInfo = info
                                                        }
                                                    }
                                                }) {
                                                    Image(systemName: "info.circle")
                                                        .foregroundColor(.blue)
                                                }
                                                .padding(.leading, 8)
                                            }
                                        }

                                        if let info = optionWithInfo.info, expandedInfo == info {
                                            Text(info)
                                                .font(Font.custom("Anuphan-Medium", size: 16))
                                                .padding()
                                                .background(Color(.systemGray6))
                                                .cornerRadius(10)
                                                .transition(.opacity.combined(with: .move(edge: .top)))
                                        }
                                    }
                                }
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

                    Button(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Submit" : "Continue") {
                        withAnimation {
                            if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
                                // If it's the last question, submit and show loading
                                isLoading = true
                                submitAnswersAndFetchPortfolios()
                            } else {
                                viewModel.goToNextQuestion()
                            }
                        }
                    }
                    .font(Font.custom("Anuphan-Medium", size: 16))
                    .disabled(viewModel.selectedAnswers.isEmpty && viewModel.customAnswer.isEmpty)
                    .padding()
                }
            }
            .padding()

            // Loading Screen
            if isLoading {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ProgressView("Generating portfolios...")
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.primary)
                        .padding()
                    Text("This might take a moment. Please wait.")
                        .font(Font.custom("Anuphan-Regular", size: 16))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.secondary)
                .cornerRadius(12)
                .shadow(radius: 10)
            }

            // NavigationLink for PortfolioDisplayView
            NavigationLink(
                destination: PortfolioDisplayView(viewModel: displayViewModel),
                isActive: $navigateToPortfolioDisplay
            ) {
                EmptyView()
            }
        }
    }

    private func submitAnswersAndFetchPortfolios() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("User not signed in.")
            isLoading = false // Stop the loading screen
            return
        }

        viewModel.compileAnswersToJSON(email: userEmail) { compiledJSON in
            guard let compiledJSON = compiledJSON else {
                print("Failed to compile answers.")
                isLoading = false // Stop the loading screen
                return
            }

            viewModel.submitAnswersToAPI(
                compiledJSON: compiledJSON,
                onPortfolioReceived: { portfolio in
                    displayViewModel.addPortfolio(portfolio)
                },
                completion: {
                    DispatchQueue.main.async {
                        isLoading = false // Stop the loading screen
                        navigateToPortfolioDisplay = true // Navigate to the display view
                    }
                }
            )
        }
    }

    private func subtitleForQuestionType(_ type: PortfolioQuestionType) -> String {
        switch type {
        case .singleSelect:
            return "Select one from the following"
        case .multiSelect:
            return "Select one or more from the following"
        default:
            return ""
        }
    }
}





#Preview {
    PortfolioGenerationView()
    }
