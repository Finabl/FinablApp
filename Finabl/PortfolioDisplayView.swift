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
    @State private var selectedGeneralExplanation: String = ""
    

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

                    if viewModel.portfolios.isEmpty {
                        // Loading View
                        Text("There was an error generating portfolios. Please try again later.")
                        /*ProgressView("Generating portfolios...")
                            .font(Font.custom("Anuphan-Regular", size: 20))
                            .padding()*/
                            
                    } else {
                        Spacer()
                        ScrollView {
                            // Portfolio List
                            VStack(spacing: 16) {
                                ForEach(viewModel.portfolios.indices, id: \.self) { index in
                                    PortfolioListItemView(portfolio: viewModel.portfolios[index]) { generalExplanation in
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            selectedGeneralExplanation = generalExplanation
                                            isModalExpanded = true
                                        }
                                    }
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
                    ZStack {
                        // Blurred Background
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    isModalExpanded = false
                                }
                            }

                        // Sliding Modal
                        ModalView(
                            isModalExpanded: $isModalExpanded,
                            generalExplanation: selectedGeneralExplanation
                        )
                        .transition(.move(edge: .bottom)) // Slide-in effect
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8)) // Smooth animation
                }
            }
        }
    }
}

struct PortfolioDetailView: View {
    let portfolio: Portfolio
    @State private var expandedStock: String? = nil // Tracks which stock's info box is expanded
    @State private var isModalExpanded: Bool = false
    @State private var selectedGeneralExplanation: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Portfolio Name
                Text(portfolio.portfolioName.components(separatedBy: "1: ")[1])
                    .font(Font.custom("Anuphan-Medium", size: 24))
                    .padding(.top)

                // Portfolio Description
                Text("\(portfolio.riskTolerance!) | \(portfolio.timeHorizon!)")
                    .font(Font.custom("Anuphan-Regular", size: 16))
                    .foregroundColor(.gray)

                // Why this portfolio
                HStack(spacing: 10) {
                    Image("elephant head") // Replace with actual logo asset
                        .resizable()
                        .frame(width: 60, height: 60)
                        .background(Color(hex: 0xF3FCFF))
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text("Why this portfolio?")
                            .font(Font.custom("Anuphan-Medium", size: 18))
                            .foregroundColor(.white)

                        Text("Fin Explains")
                            .font(Font.custom("Anuphan-Regular", size: 14))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(hex: 0x105A90))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedGeneralExplanation = portfolio.generalExplanation
                        isModalExpanded = true
                    }
                }

                // Stocks/ETFs Section
                VStack(spacing: 10) {
                    ForEach(portfolio.stocksETFs) { stock in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(stock.ticker)
                                    .font(Font.custom("Anuphan-Medium", size: 18))
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(stock.allocation)")
                                    .font(Font.custom("Anuphan-Regular", size: 16))
                                    .foregroundColor(.gray)

                                Button(action: {
                                    withAnimation {
                                        if expandedStock == stock.ticker {
                                            expandedStock = nil
                                        } else {
                                            expandedStock = stock.ticker
                                        }
                                    }
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 18))
                                }
                            }

                            if expandedStock == stock.ticker {
                                Text(stock.justification)
                                    .font(Font.custom("Anuphan-Medium", size: 16))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
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
                            .foregroundColor(.primary)
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
        .overlay(
            ZStack {
                if isModalExpanded {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isModalExpanded = false
                            }
                        }
                    ModalView(
                        isModalExpanded: $isModalExpanded,
                        generalExplanation: selectedGeneralExplanation
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        )
    }
}

struct PortfolioListItemView: View {
    let portfolio: Portfolio
    let onExpand: (String) -> Void

    var body: some View {
        NavigationLink(destination: PortfolioDetailView(portfolio: portfolio)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(portfolio.portfolioName.components(separatedBy: "1: ")[1])
                        .font(Font.custom("Anuphan-Medium", size: 18))
                        .foregroundColor(.primary)

                    Text(portfolio.generalExplanation)
                        .font(Font.custom("Anuphan-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Button(action: {
                    onExpand(portfolio.generalExplanation) // Pass general explanation to callback
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

struct ModalView: View {
    @Binding var isModalExpanded: Bool
    let generalExplanation: String // Accept general explanation

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isModalExpanded.toggle() // Collapse modal
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            Image("fin")
                                .resizable()
                                .frame(width: 100, height: 100)
                            VStack(alignment: .leading) {
                                Text("Why this portfolio?")
                                    .font(Font.custom("Anuphan-Bold", size: 24))
                                    .foregroundColor(.white)
                                VStack(alignment: .leading) {
                                    Text("Fin explains")
                                        .font(Font.custom("Anuphan-Medium", size: 18))
                                        .foregroundColor(.white)
                                }

                            }

                            
                        }
                        //.padding()
                        Text(generalExplanation) // Display the general explanation
                            .font(Font.custom("Anuphan-Regular", size: 16))
                            .foregroundColor(Color.white.opacity(0.95))
                            .multilineTextAlignment(.leading)
                            .padding()
                    }

                    Spacer()
                }
                .frame(height: geometry.size.height * 0.6)
                .background(Color(hex: 0x105A90))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: -4)
            }
        }
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
