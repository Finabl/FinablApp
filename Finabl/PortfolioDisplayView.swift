//
//  PortfolioDisplayView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/31/24.
//

import SwiftUI

struct PortfolioDisplayView: View {
    @ObservedObject var viewModel: PortfolioDisplayViewModel
    @State private var isModalExpanded: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    Spacer()
                    Text("Here are some recommended portfolios!")
                        .font(Font.custom("Anuphan-Medium", size: 26))
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    Spacer()

                    if viewModel.portfolios.isEmpty {
                        // Loading View
                        ProgressView("Generating portfolios...")
                            .font(Font.custom("Anuphan-Regular", size: 20))
                            .padding()
                    } else {
                        ScrollView {
                            // Portfolio List
                            VStack(spacing: 16) {
                                ForEach(viewModel.portfolios.indices, id: \.self) { index in
                                    PortfolioListItemView(portfolio: viewModel.portfolios[index])
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                        .animation(.easeInOut(duration: 0.5).delay(0.2 * Double(index)), value: viewModel.portfolios)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                .blur(radius: isModalExpanded ? 10 : 0) // Blur the background when modal is expanded

                // Expandable Modal
                if isModalExpanded {
                    ModalView(isModalExpanded: $isModalExpanded)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut)
                }
            }
        }
    }
}

struct PortfolioListItemView: View {
    let portfolio: Portfolio
    @State private var isModalExpanded: Bool = false

    var body: some View {
        NavigationLink(destination: PortfolioDetailView(portfolio: portfolio)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(portfolio.portfolioName.components(separatedBy: "1: ")[1])
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.black)

                    Text(portfolio.generalExplanation)
                        .font(Font.custom("Anuphan-Regular", size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        isModalExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}


struct PortfolioDetailView: View {
    let portfolio: Portfolio
    @State private var isModalExpanded: Bool = false // State to toggle modal visibility

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Portfolio Name
                Text(portfolio.portfolioName.components(separatedBy: "1: ")[1])
                    .font(Font.custom("Anuphan-Medium", size: 24))
                    .padding(.top)

                // Portfolio Description
                Text(portfolio.generalExplanation)
                    .font(Font.custom("Anuphan-Regular", size: 16))
                    .foregroundColor(.gray)

                // Why this portfolio
                HStack {
                    Spacer()
                    Image("elephant head") // Replace with actual logo asset
                        .resizable()
                        .frame(width: 60, height: 60)
                        .background(Color(hex: 0xF3FCFF))
                        .clipShape(Circle())
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Why this portfolio?")
                            .font(Font.custom("Anuphan-Medium", size: 18))
                            .foregroundColor(.white)

                        Text("We recommend this portfolio for...")
                            .font(Font.custom("Anuphan-Regular", size: 14))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(Color(hex: 0x105A90))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isModalExpanded.toggle() // Toggle modal visibility
                    }
                }

                // Stocks/ETFs
                HStack {
                    Text("Total")
                        .font(Font.custom("Anuphan-Medium", size: 18))

                    Spacer()
                    Text("100%")
                        .font(Font.custom("Anuphan-Regular", size: 18))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)

                Divider()
                VStack {
                    ForEach(portfolio.stocksETFs) { stock in
                        HStack {
                            Text(stock.ticker)
                                .font(Font.custom("Anuphan-Medium", size: 18))

                            Spacer()
                            Text("\(stock.allocation)")
                                .font(Font.custom("Anuphan-Regular", size: 18))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                Spacer()

                // Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        // Handle paper trading
                    }) {
                        Text("Paper/Simulated")
                            .font(Font.custom("Anuphan-Medium", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // Handle real trading
                    }) {
                        Text("Real")
                            .font(Font.custom("Anuphan-Medium", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationBarTitle("", displayMode: .inline)
        .overlay(
            Group {
                if isModalExpanded {
                    ModalView(isModalExpanded: $isModalExpanded) // Bind modal state here
                        .transition(.move(edge: .bottom)) // Slide in from the bottom
                }
            }
        )
    }
}

struct ModalView: View {
    @Binding var isModalExpanded: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isModalExpanded.toggle() // Collapse modal
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }

                    Text("Why this portfolio?")
                        .font(Font.custom("Anuphan-Medium", size: 24))
                        .padding(.bottom, 4)

                    Text("We recommend this portfolio for users looking for conservative risk profiles.")
                        .font(Font.custom("Anuphan-Regular", size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()
                }
                .frame(height: geometry.size.height * 0.6)
                .background(Color(hex: 0x105A90))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: -4)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}



// Mock Data for Previews
extension Portfolio {
    static let mockPortfolios: [Portfolio] = [
        Portfolio(
            portfolioName: "Portfolio 1: High-Risk/Reward Portfolio",
            generalExplanation: "Maximizing profits with high risk.",
            timeHorizon: "Less than 1 year",
            riskTolerance: "High",
            stocksETFs: [
                .init(ticker: "AAPL", allocation: "40%", riskLevel: "High", justification: "Growth potential."),
                .init(ticker: "MSFT", allocation: "30%", riskLevel: "Moderate", justification: "Stable growth."),
                .init(ticker: "GOOG", allocation: "30%", riskLevel: "High", justification: "Strong market position.")
            ]
        ),
        Portfolio(
            portfolioName: "Portfolio 1: Intermediate Portfolio",
            generalExplanation: "Balanced risk and reward.",
            timeHorizon: "1-3 years",
            riskTolerance: "Moderate",
            stocksETFs: [
                .init(ticker: "TSLA", allocation: "25%", riskLevel: "High", justification: "Growth potential."),
                .init(ticker: "AMZN", allocation: "50%", riskLevel: "Moderate", justification: "Market leader."),
                .init(ticker: "BND", allocation: "25%", riskLevel: "Low", justification: "Diversification.")
            ]
        )
    ]
}
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

#Preview {
    PortfolioDisplayView(viewModel: PortfolioDisplayViewModel(portfolios: Portfolio.mockPortfolios))
}
