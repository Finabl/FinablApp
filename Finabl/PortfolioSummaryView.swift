//
//  PortfolioSummaryView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/27/24.
//

import SwiftUI

struct PortfolioSummaryView: View {
    let questions: [(text: String, type: PortfolioQuestionType)]
    let answers: [Int: String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Selections")
                    .font(Font.custom("Anuphan-Bold", size: 28))
                    .padding(.bottom, 10)

                ForEach(questions.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(index + 1). \(questions[index].text)")
                            .font(Font.custom("Anuphan-Medium", size: 18))
                            .foregroundColor(.primary)

                        if let answer = answers[index], !answer.isEmpty {
                            Text("Answer: \(answer)")
                                .font(Font.custom("Anuphan-Regular", size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}
