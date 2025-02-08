//
//  ReviewView.swift
//  Finabl
//
//  Created by Pratham Madaram on 2/8/25.
//

import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Title
                Text("Lesson complete!")
                    .font(.custom("Anuphan-Medium", size: 24))
                
                // Elephant image (replace "elephant" with your actual image asset)
                Image("fin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                // Star rating
                HStack(spacing: 8) {
                    // Four filled stars
                    ForEach(0..<4) { _ in
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    // One empty star
                    Image(systemName: "star")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.5))
                }
                
                // Overview card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.black)
                    Text("You did a great job during this lesson! You learned about options and how to put a call option!")
                        .font(.custom("Anuphan-Medium", size: 16))
                        .foregroundColor(.black)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Recommendations card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations")
                        .font(.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.black)
                    Text("Go over what the difference between a strike price and premium is.")
                        .font(.custom("Anuphan-Medium", size: 16))
                        .foregroundColor(.black)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Continue button
                NavigationLink(destination: LearnHubView()) {
                    Text("Submit")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            // "X" button in the top-right
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    ReviewView()
}
