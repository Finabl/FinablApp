//
//  Module1View.swift
//  Finabl
//
//  Created by Pratham Madaram on 2/8/25.
//

import SwiftUI

struct CoursePageView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Just a spacer at the top for visual breathing room
                Spacer()
                
                // Placeholder "chart" icon
                Image("fin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.gray)
                
                // Hard-coded lesson title and description
                Text("1.1 Intro to Options Investing")
                    .font(.custom("Anuphan-Medium", size: 24))
                
                Text("Venture into the world of options investing! ").font(.custom("Anuphan-Medium", size: 16))
                    .foregroundColor(.gray)
                
                // Navigation link to go to the lesson article
                NavigationLink(destination: LessonArticleView()) {
                    Text("Start Lesson")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Push content up from bottom
                Spacer()
            }
            .padding()
            .navigationBarTitle("Options Investing", displayMode: .inline)
        }
    }
}
#Preview {
    CoursePageView()
}
