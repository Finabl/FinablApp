//
//  HomeView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/1/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var firstName: String = "Sid" // Default placeholder for firstName
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var portfolios = [
        AlpacaPortfolio(
            portfolioId: "uuid1",
            portfolioName: "Tech Stocks",
            usernames: ["user1@example.com", "user2@example.com"],
            alpacaId: "alpaca123",
            stockAllocation: [
                StockAllocation(ticker: "AAPL", percentage: 0.5, shares: 10),
                StockAllocation(ticker: "MSFT", percentage: 0.3, shares: 15),
                StockAllocation(ticker: "GOOGL", percentage: 0.2, shares: 5)
            ],
            stocks: [
                Stock(ticker: "AAPL", shares: 10),
                Stock(ticker: "MSFT", shares: 15)
            ],
            transactions: [
                Transaction(
                    id: "txn1",
                    shares: 5,
                    ticker: "AAPL",
                    dollarAmount: 750.0,
                    datetime: "2025-01-03T12:00:00Z",
                    type: "buy"
                ),
                Transaction(
                    id: "txn2",
                    shares: 3,
                    ticker: "MSFT",
                    dollarAmount: 500.0,
                    datetime: "2025-01-04T14:00:00Z",
                    type: "sell"
                )
            ]
        ),
        AlpacaPortfolio(
            portfolioId: "uuid2",
            portfolioName: "asdfasf Stocks",
            usernames: ["user1@example.com", "user2@example.com"],
            alpacaId: "alpaca123",
            stockAllocation: [
                StockAllocation(ticker: "AAPL", percentage: 0.5, shares: 10),
                StockAllocation(ticker: "MSFT", percentage: 0.3, shares: 15),
                StockAllocation(ticker: "GOOGL", percentage: 0.2, shares: 5)
            ],
            stocks: [
                Stock(ticker: "AAPL", shares: 10),
                Stock(ticker: "MSFT", shares: 15)
            ],
            transactions: [
                Transaction(
                    id: "txn1",
                    shares: 5,
                    ticker: "AAPL",
                    dollarAmount: 750.0,
                    datetime: "2025-01-03T12:00:00Z",
                    type: "buy"
                ),
                Transaction(
                    id: "txn2",
                    shares: 3,
                    ticker: "MSFT",
                    dollarAmount: 500.0,
                    datetime: "2025-01-04T14:00:00Z",
                    type: "sell"
                )
            ]
        ),
        AlpacaPortfolio(
            portfolioId: "uuid3",
            portfolioName: "adfasdf Stocks",
            usernames: ["user1@example.com", "user2@example.com"],
            alpacaId: "alpaca123",
            stockAllocation: [
                StockAllocation(ticker: "AAPL", percentage: 0.5, shares: 10),
                StockAllocation(ticker: "MSFT", percentage: 0.3, shares: 15),
                StockAllocation(ticker: "GOOGL", percentage: 0.2, shares: 5)
            ],
            stocks: [
                Stock(ticker: "AAPL", shares: 10),
                Stock(ticker: "MSFT", shares: 15)
            ],
            transactions: [
                Transaction(
                    id: "txn1",
                    shares: 5,
                    ticker: "AAPL",
                    dollarAmount: 750.0,
                    datetime: "2025-01-03T12:00:00Z",
                    type: "buy"
                ),
                Transaction(
                    id: "txn2",
                    shares: 3,
                    ticker: "MSFT",
                    dollarAmount: 500.0,
                    datetime: "2025-01-04T14:00:00Z",
                    type: "sell"
                )
            ]
        )
    ]

    let greenColor = Color(hex: 0x30E7D1)
    var body: some View {
        VStack {
            // Top Navigation Bar
            HStack {
                Image("elephant head")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("Finabl")
                    .font(Font.custom("Anuphan-Medium", size: 18))
                    .foregroundColor(.primary)
                Spacer()
                
            }
            .padding(.horizontal)
        }
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hi \(firstName), welcome back!")
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
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(greenColor)))
                            .cornerRadius(10)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
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
                                    Text(portfolio.portfolioName)
                                        .font(Font.custom("Anuphan-Regular", size: 14))
                                        .foregroundColor(.gray)
                                    //Text("$\(String(format: "%.2f", portfolio.balance))")
                                      //  .font(Font.custom("Anuphan-Bold", size: 18))


                                    HStack {
                                        Spacer()
                                        VStack {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 50)
                                                .foregroundColor(.green)
                                            //Text("\(portfolio.growth > 0 ? "+" : "")\(String(format: "%.2f", portfolio.growth))%")
                                             //   .font(Font.custom("Anuphan-Regular", size: 14))
                                              //  .foregroundColor(.green)
                                        }
                                    }.frame(maxWidth: .infinity)

                                }
                                .frame(width: 150, alignment: .leading)
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
                                .progressViewStyle(LinearProgressViewStyle(tint: greenColor))
                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
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
        }.onAppear {
            fetchUserData()
        }
    }

    private func fetchUserData() {
        // Firebase Authentication to fetch the user's email
        guard let user = Auth.auth().currentUser else {
            print("No user signed in")
            self.isLoading = false
            return
        }

        let email = user.email ?? ""

        // Fetch user details
        fetchFirstName(email: email)
        fetchPortfolios(email: email)
    }

    private func fetchFirstName(email: String) {
        guard let url = URL(string: "https://app.finabl.org/api/users/user/\(email)") else {
            print("Invalid URL for fetching user first name")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching first name: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received for first name")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let fetchedFirstName = json["firstName"] as? String {
                    DispatchQueue.main.async {
                        self.firstName = fetchedFirstName
                    }
                }
            } catch {
                print("Error parsing first name JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func fetchPortfolios(email: String) {
        guard let url = URL(string: "https://app.finabl.org/api/portfolios/user-portfolios?email=\(email)") else {
            print("Invalid URL for fetching portfolios")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching portfolios: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received for portfolios")
                return
            }

            do {
                // Decode the root response first
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                let decodedResponse = try JSONDecoder().decode(RootResponse.self, from: data)
                DispatchQueue.main.async {
                    // Access the portfolios array from the decoded response
                    self.portfolios = decodedResponse.portfolios
                }
            } catch {
                print("Error decoding portfolio JSON: \(error)")
            }
        }.resume()
    }
}



#Preview {
    HomeView()
}
