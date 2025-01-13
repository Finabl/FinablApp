//
//  LearnHub.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/8/25.
//

import SwiftUI

struct LearnHubView: View {
    var body: some View {
                // Main Scrollable Content
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("Learning Hub")
                        .font(Font.custom("Anuphan-Medium", size: 20))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Daily Tasks Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Daily Tasks")
                                .font(.custom("Anuphan-Medium", size: 18))
                                .padding(.horizontal)

                            // Horizontal Date Scroll
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(17...21, id: \.self) { day in
                                        VStack(spacing: 5) {
                                            Circle()
                                                .fill(day <= 19 ? Color.green : Color.secondary.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Text("Nov \(day)")
                                                .font(.custom("Anuphan-Regular", size: 14))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Tasks
                            VStack(spacing: 10) {
                                TaskRow(title: "Lesson Module", subtitle: "Intro to Options Investing")
                                TaskRow(title: "Market Moments Quiz", subtitle: "11/17 Market Moments Quiz")
                            }
                        }

                        // Continue Learning Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Continue Learning")
                                .font(.custom("Anuphan-Medium", size: 18))
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                        LearningCard(
                                            title: "1.10 Intro to Options Trading",
                                            subtitle: "Intro to Investing"
                                        )

                                        LearningCard(
                                            title: "1.2 How to purchase and sell Bonds",
                                            subtitle: "Investing in the Government: Bonds"
                                        )
                                    
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Your Courses Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Courses")
                                .font(.custom("Anuphan-Medium", size: 18))
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                        CourseCard(
                                            courseName: "Course Name",
                                            moduleName: "1.1 Section Name"
                                        )
                                        CourseCard(
                                            courseName: "Course Name",
                                            moduleName: "1.2 Section Name"
                                        )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
    }
}


// Reusable Components
struct TaskRow: View {
    var title: String
    var subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.custom("Anuphan-Medium", size: 16))
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.custom("Anuphan-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct LearningCard: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Anuphan-Medium", size: 16))
            Text(subtitle)
                .font(.custom("Anuphan-Regular", size: 14))
                .foregroundColor(.gray)
            NavigationLink(destination: CourseDetailView(moduleName: title, description: subtitle).navigationBarBackButtonHidden()) {
                Text("Continue")
                    .font(.custom("Anuphan-Medium", size: 16))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
            }
        }
        .padding()
        .frame(width: 200, height: 160)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CourseCard: View {
    var courseName: String
    var moduleName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(courseName)
                .font(.custom("Anuphan-Medium", size: 16))
            Text(moduleName)
                .font(.custom("Anuphan-Regular", size: 14))
                .foregroundColor(.gray)

            ProgressView(value: 0.5)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            NavigationLink(destination: CourseDetailView(moduleName: courseName, description: moduleName).navigationBarBackButtonHidden()) {
                Text("Continue")
                    .font(.custom("Anuphan-Medium", size: 16))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
            }

        }
        .padding()
        .frame(width: 200)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// Preview
#Preview {
    LearnHubView()
}
