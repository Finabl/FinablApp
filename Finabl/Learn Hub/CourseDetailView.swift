//
//  CourseDetailView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/8/25.
//

import SwiftUI

// Course Detail View
struct CourseDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    var moduleName: String
    var description: String

    var body: some View {
        
        VStack {
            // Custom Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text(moduleName)
                    .font(Font.custom("Anuphan-Medium", size: 18))
                    .foregroundColor(.primary)
                    Spacer()
                Button(action: {
                    //presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary).colorInvert()
                }
            }
            .padding()


            Spacer()

            // Lesson Card
            VStack {
                Text(moduleName)
                    .font(Font.custom("Anuphan-Medium", size: 18))
                Text(description)
                    .font(Font.custom("Anuphan-Regular", size: 14))
                    .foregroundColor(.gray)
                Button(action: {
                    // Start lesson action
                }) {
                    Text("Start Lesson")
                        .font(Font.custom("Anuphan-Medium", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .padding()
            .padding(.bottom, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)

        }
    }
}

#Preview {
    CourseDetailView(moduleName: "Test Module", description: "Pratham Description")
}
