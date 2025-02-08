//
//  LessonArticleView.swift
//  Finabl
//
//  Created by Pratham Madaram on 2/8/25.
//

import SwiftUI

struct LessonArticleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Title
                Text("Intro to Options Investing")
                    .font(.custom("Anuphan-Medium", size: 24))

                // Subtitle
                Text("Introduction")
                    .font(.custom("Anuphan-Medium", size: 18))

                // Intro text
                Text("""
Imagine options as special coupons for shopping. These coupons give you the right, but not the obligation, to buy or sell something at a fixed price before a certain date. You’re not buying the item itself, just the coupon.
""")
                .font(.custom("Anuphan-Medium", size: 16))

                // Key parts heading
                Text("Key Parts of an Option")
                    .font(.custom("Anuphan-Medium", size: 18))

                // Strike Price
                Text("Strike Price: The price you can buy or sell at (like the price on the coupon).")
                    .font(.custom("Anuphan-Medium", size: 16))

                // Dot on the next line for style
                Text(".")
                    .font(.custom("Anuphan-Medium", size: 16))
                    .foregroundColor(.gray)

                // Expiration Date
                Text("Expiration Date: The last day you can use the coupon.")
                    .font(.custom("Anuphan-Medium", size: 16))

                // Premium
                Text("Premium: The cost of the coupon itself.")
                    .font(.custom("Anuphan-Medium", size: 16))

                // Option diagram image (replace "option_graph" with your actual asset name)
                Image("optionsgraph")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)

                // Call Options heading
                Text("Call Options")
                    .font(.custom("Anuphan-Medium", size: 18))

                // Call Options description
                Text("""
A call option is like a coupon that lets you buy a product at a fixed price, even if the store price goes up. This means that you will buy a call when you think the price of a stock will go up. Imagine buying a coupon for $18 (The Premium) that lets you get a product for $420 (The Strike Price) until 2 weeks after (The Expiration Date) the order. If the product’s price rises to $450, you can still buy it for $420 using your coupon, saving $30. After subtracting the $18 you spent on the coupon, you just made $12!
""")
                .font(.custom("Anuphan-Medium", size: 16))

                // Next button
                NavigationLink(destination: QuizView()) {
                    Text("Start Lesson")
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


#Preview {
    LessonArticleView()
}
