//
//  HomeView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/1/25.
//

import SwiftUI

struct HomeView: View {
    let portfolios = [
        AlpacaPortfolio(name: "Portfolio A", balance: 1000.00, growth: 5.0),
        AlpacaPortfolio(name: "Portfolio B", balance: 1500.00, growth: 2.5),
        AlpacaPortfolio(name: "Portfolio C", balance: 750.00, growth: -1.2)
    ]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hi Sid, welcome back!")
                        .font(Font.custom("Anuphan-Bold", size: 24))
                    Text("View your progress at a glance.")
                        .font(Font.custom("Anuphan-Medium", size: 16))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Overall growth")
                            .font(Font.custom("Anuphan-Medium", size: 14))
                            .foregroundColor(.gray)
                        Text("+$50.00")
                            .font(Font.custom("Anuphan-Medium", size: 24))
                        ProgressView(value: 0.3)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                    }
                }
                .padding(.horizontal)
                VStack {
                    Rectangle()
                        .fill(Color(UIColor.systemGray4))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                    
                }.padding()
                // Portfolios Section
                // Portfolio Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Portfolios")
                            .font(Font.custom("Anuphan-Bold", size: 18))
                        Spacer()
                        NavigationLink(destination: AlpacaPortfolioListView(portfolios: portfolios).navigationBarBackButtonHidden(true)) {
                            Text("See all")
                                .font(Font.custom("Anuphan-Regular", size: 14))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(portfolios) { portfolio in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(portfolio.name)
                                        .font(Font.custom("Anuphan-Regular", size: 14))
                                        .foregroundColor(.gray)
                                    Text("$\(String(format: "%.2f", portfolio.balance))")
                                        .font(Font.custom("Anuphan-Bold", size: 18))
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                        .foregroundColor(.green)
                                    Text("\(portfolio.growth > 0 ? "+" : "")\(String(format: "%.2f", portfolio.growth))%")
                                        .font(Font.custom("Anuphan-Regular", size: 14))
                                        .foregroundColor(.green)
                                }
                                .frame(width: 150)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Goals Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Goals")
                            .font(Font.custom("Anuphan-Bold", size: 18))
                        Spacer()
                        Button(action: {
                            // Add goal action
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                    ForEach(0..<2) { _ in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Invest $200")
                                    .font(Font.custom("Anuphan-Regular", size: 16))
                                Spacer()
                                Text("35%")
                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            ProgressView(value: 0.35)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Watchlists Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Watchlists")
                            .font(Font.custom("Anuphan-Bold", size: 18))
                        Spacer()
                        Text("2")
                            .font(Font.custom("Anuphan-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    ForEach(0..<2) { _ in
                        HStack {
                            Text("Watchlist name")
                                .font(Font.custom("Anuphan-Regular", size: 16))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // News Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("News")
                        .font(Font.custom("Anuphan-Bold", size: 18))
                    ForEach(0..<2) { _ in
                        HStack(alignment: .top, spacing: 10) {
                            Rectangle()
                                .fill(Color(UIColor.systemGray4))
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Article title Article title Article title")
                                    .font(Font.custom("Anuphan-SemiBold", size: 14))
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                                    .font(Font.custom("Anuphan-Regular", size: 12))
                                    .foregroundColor(.gray)
                                Text("1h")
                                    .font(Font.custom("Anuphan-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }

    }
}



#Preview {
    HomeView()
}
