//
//  PortfolioGenerationView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/24/24.
//

import SwiftUI

struct InfoItem: Identifiable {
    let id = UUID()
    let text: String
}

struct PortfolioGenerationView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = PortfolioGenerationViewModel()
    @State private var expandedInfo: String? = nil // Tracks which option's info box is expanded

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isCompleted {
                // Summary View
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Summary of Your Answers")
                            .font(Font.custom("Anuphan-Medium", size: 24))
                            .fontWeight(.bold)
                            .padding(.bottom, 10)

                        ForEach(viewModel.answersSummary.keys.sorted(), id: \.self) { question in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(question)
                                    .font(Font.custom("Anuphan-Medium", size: 18))
                                    .fontWeight(.semibold)

                                ForEach(viewModel.answersSummary[question] ?? [], id: \.self) { answer in
                                    Text("- \(answer)")
                                        .font(Font.custom("Anuphan-Regular", size: 16))
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 16) {
                    ZStack(alignment: .leading) {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.progress)

                        GeometryReader { geometry in
                            Image("elephant head")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                                .offset(x: CGFloat(viewModel.progress) * (geometry.size.width - 50))
                                .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
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
            }

            Spacer()

            HStack {
                Button("Back") {
                    withAnimation {
                        viewModel.goToPreviousQuestion()
                    }
                }
                .disabled(viewModel.currentQuestionIndex == 0)
                .padding()

                Spacer()

                Button("Continue") {
                    withAnimation {
                        if viewModel.isCompleted {
                            print("Final Answers: \(viewModel.answersSummary)")
                        } else {
                            viewModel.goToNextQuestion()
                        }
                    }
                }
                .disabled(viewModel.selectedAnswers.isEmpty && viewModel.customAnswer.isEmpty)
                .padding()
            }
        }
        .padding()
    }

    // Helper function for subtitle text
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
