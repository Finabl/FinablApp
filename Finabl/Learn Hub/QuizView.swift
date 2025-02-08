//
//  QuizView.swift
//  Finabl
//
//  Created by Pratham Madaram on 2/8/25.
//

import SwiftUI

struct QuizView: View {
    // State to track the currently selected option index
    @State private var selectedOptionIndex: Int? = nil
    
    // Example question data
    let questionText = "In this graph below, how much does the stock need to be worth to break-even on the call option?"
    let options = [
        "$100",
        "$95",
        "$105",
        "$120"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // The quiz question
                Text(questionText)
                    .font(.custom("Anuphan-Medium", size: 18))
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                // Image placeholder (replace with your actual asset name)
                Image("quizgraph")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Multiple-choice options
                ForEach(options.indices, id: \.self) { index in
                    OptionRow(
                        text: options[index],
                        isSelected: selectedOptionIndex == index
                    )
                    .onTapGesture {
                        selectedOptionIndex = index
                    }
                }
                
                // Submit button
                NavigationLink(destination: ReviewView()) {
                    Text("Submit")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
                
            }
            .padding()
        }
        .navigationTitle("Lesson 10")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - OptionRow
/// A row showing each option with a highlighted background if selected.
struct OptionRow: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .font(.custom("Anuphan-Medium", size: 16))
                .foregroundColor(.black)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    QuizView()
}
