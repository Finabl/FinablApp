//
//  AlpacaPortfolioSpecificView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/9/25.
//

import SwiftUI
import LinkKit
import FirebaseAuth

struct AlpacaPortfolioSpecificView: View {
    @State private var selectedTimeRange: String = "1D"
    @State private var isLoading = true
    @State private var email: String = "user@example.com"
    var portfolio: AlpacaPortfolio
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var stockPrices: [String: Double] = [:] // Holds stock prices for each ticker
    let publicToken = UserDefaults.standard.string(forKey: "PlaidPublicToken") ?? ""
    let accountId = UserDefaults.standard.string(forKey: "PlaidAccountId") ?? ""
    @State private var lineChartData: [Candlestick] = []

    @State private var selectedTab: String = "Overview" // Tracks the selected tab
    @State private var depositAmount: String = "100" // For entering deposit amounts
    @State private var isTransferInProgress = false // Tracks transfer progress
    @State private var isPresentingLink = false
    private let fmpAPI = FMPAPI()
    // Mapping for date ranges
    private let timeRangeMapping: [String: Int] = [
        "1D": 1,
        "5D": 5,
        "1M": 30,
        "3M": 90,
        "1Y": 365,
        "3Y": 1095,
        "Max": 1825
    ]
    private var linkController: LinkController?

    init(portfolio: AlpacaPortfolio) {
        self.portfolio = portfolio
        // Create a Handler right away so Link can begin loading prior to the user pressing the button.
        /*let createResult = createHandler()
        switch createResult {
        case .failure(let createError):
            print("Link Creation Error: \(createError.localizedDescription)")
        case .success(let handler):
            linkController = LinkController(handler: handler)
        }*/
    }
    
    var body: some View {
        VStack {
            // Custom Top Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text(portfolio.portfolioName)
                    .font(Font.custom("Anuphan-Medium", size: 18))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    // Settings or options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Tab Bar for Overview, Stocks, History
            ZStack (alignment: .bottom) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = "Overview"
                        }
                    }) {
                        Text("Overview")
                            .font(Font.custom("Anuphan-Bold", size: 16))
                            .foregroundColor(selectedTab == "Overview" ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = "Stocks"
                        }
                    }) {
                        Text("Stocks")
                            .font(Font.custom("Anuphan-Bold", size: 16))
                            .foregroundColor(selectedTab == "Stocks" ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = "History"
                        }
                    }) {
                        Text("History")
                            .font(Font.custom("Anuphan-Bold", size: 16))
                            .foregroundColor(selectedTab == "History" ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    Spacer()
                }
                .padding(.bottom, 8)

                // Underline
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: 80, height: 2) // Fixed underline width for consistent appearance
                        .foregroundColor(.blue)
                        .offset(
                            x: selectedTab == "Overview" ? -UIScreen.main.bounds.width / 3 :
                                selectedTab == "Stocks" ? 0 :
                                UIScreen.main.bounds.width / 3
                        )
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
            }


            
            // Content Area

            VStack(alignment: .leading) {
                if selectedTab == "Overview" {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Portfolio Name and Balance Section
                            VStack(alignment: .leading, spacing: 4) {
                                Text(portfolio.portfolioName)
                                    .font(Font.custom("Anuphan-Bold", size: 20))
                                /*Text("$\(String(format: "%.2f", portfolio.balance))")
                                    .font(Font.custom("Anuphan-Bold", size: 28))
                                Text("+$\(String(format: "%.2f", portfolio.balance * portfolio.growth / 100)) (\(portfolio.growth > 0 ? "+" : "")\(String(format: "%.2f", portfolio.growth))%) today")
                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                    .foregroundColor(portfolio.growth >= 0 ? .green : .red)*/
                            }
                            .padding(.horizontal)
                            
                            // Line Chart Placeholder
                            VStack {
                                /*Rectangle()
                                    .fill(Color(UIColor.systemGray6))
                                    .frame(height: 200)
                                    .cornerRadius(10)*/
                                if isLoading {
                                    Text("Loading data...")
                                        .onAppear {
                                            fetchData()
                                            print("hai")
                                        }
                                } else if lineChartData.isEmpty {
                                    Text("No data available")
                                } else {
                                   LineChart(data: lineChartData)
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                        .background(.blue.opacity(0.2))
                                        //.padding()
                                }
                            }
                            .padding(.horizontal)
                            
                            // Time Range Buttons
                            HStack(spacing: 12) {
                                ForEach(["1D", "1M", "3M", "1Y", "3Y", "More"], id: \.self) { timeRange in
                                    Button(action: {
                                        // Add time range action
                                    }) {
                                        Text(timeRange)
                                            .font(Font.custom("Anuphan-Regular", size: 14))
                                            .foregroundColor(timeRange == "1D" ? .blue : .gray) // Highlight active button
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                timeRange == "1D" ? Color.blue.opacity(0.1) : Color.clear
                                            )
                                            .cornerRadius(8)
                                        
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Buying Power Section
                            HStack {
                                Text("Buying power")
                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                Spacer()
                                Text("$1000.00") // Placeholder for 10% buying power
                                    .font(Font.custom("Anuphan-Bold", size: 14))
                                /*HStack {
                                    Button(action: { isPresentingLink = true }) {
                                        Text("Link Account")
                                            .font(Font.custom("Anuphan-Bold", size: 18))
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(50)
                                    }
                                    Button(action: initiateDeposit) {
                                        Text("Add Money")
                                            .font(Font.custom("Anuphan-Bold", size: 18))
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(50)
                                    }
                                    .disabled(depositAmount.isEmpty || isTransferInProgress)
                                }
                                .padding(.horizontal)*/
                                /*Button(action: {
                                    print("button clicked")
                                    //showPlaidLink(amount: 100.0, userEmail: email)
                                    isPresentingLink = true
                                }) {
                                    Text("Add Money")
                                        .padding(5)
                                        .font(Font.custom("Anuphan-Regular", size: 14))
                                        .background(.green)
                                        .cornerRadius(10)
                                }*/
                                
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Asset Allocation Section
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Asset Allocation")
                                        .font(Font.custom("Anuphan-Bold", size: 16))
                                    Spacer()
                                    Button(action: {
                                        // See all action
                                    }) {
                                        Text("See all")
                                            .font(Font.custom("Anuphan-Regular", size: 14))
                                            .foregroundColor(.blue)
                                    }
                                }
                                // Pie Chart Placeholder
                                HStack {
                                    Circle()
                                        .fill(Color(UIColor.systemGray6))
                                        .frame(width: 100, height: 100)
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(["Metric 1", "Metric 2", "Metric 3"], id: \.self) { metric in
                                            HStack {
                                                Circle()
                                                    .fill(Color.gray) // Placeholder for color indicators
                                                    .frame(width: 10, height: 10)
                                                Text(metric)
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Related News Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Related News")
                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                ForEach(0..<2) { _ in
                                    HStack(alignment: .top, spacing: 12) {
                                        Rectangle()
                                            .fill(Color(UIColor.systemGray6))
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Article title Article title Article title")
                                                .font(Font.custom("Anuphan-Bold", size: 14))
                                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                                                .font(Font.custom("Anuphan-Regular", size: 12))
                                                .foregroundColor(.gray)
                                            Text("1h")
                                                .font(Font.custom("Anuphan-Regular", size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                } else if selectedTab == "Stocks" {
                    // Stocks Content
                    VStack(spacing: 0) {
                        // Search Bar
                        HStack {
                            TextField("Search", text: .constant("")) // Replace with @State variable if needed
                                .padding(10)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            Button(action: {
                                // Sorting action
                            }) {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing)
                        }
                        .padding(.vertical, 8)
                        
                        // Stock List
                        ScrollView {
                            VStack(spacing: 1) {
                                ForEach(portfolio.stocks, id: \.ticker) { stock in
                                    NavigationLink(destination: AlpacaStockView(ticker: stock.ticker).navigationBarBackButtonHidden()) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(stock.ticker)
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("\(stock.shares) shares")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()

                                            Text("$\(String(format: "%.2f", (Double(stock.shares) * (stockPrices[stock.ticker] ?? 0.0))))")
                                                .font(Font.custom("Anuphan-Regular", size: 16))
                                    }
                                    }
                                    .foregroundStyle(.primary)
                                    .padding()
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(8)
                                    .onAppear {
                                        fetchStockPrice(for: stock.ticker)
                                    }
                                }
                            }
                        }
                    }
                } else if selectedTab == "History" {
                    VStack(spacing: 0) {
                        // Search Bar
                        HStack {
                            TextField("Search", text: .constant("")) // Replace with @State variable if needed
                                .padding(10)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            Button(action: {
                                // Sorting action
                            }) {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing)
                        }
                        .padding(.vertical, 8)
                        
                        // History Section
                        ScrollView {
                            VStack(spacing: 16) {
                                // First Date Group
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("December 19, 2023")
                                        .font(Font.custom("Anuphan-Bold", size: 16))
                                    
                                    VStack(spacing: 12) {
                                        // History Item 1
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Dividend")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .padding(4)
                                                    .background(Color(UIColor.systemGray6))
                                                    .cornerRadius(4)
                                                Text("AAAA")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("1 share")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("$0.00")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("+$0.00")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        
                                        // History Item 2
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Sell")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .padding(4)
                                                    .background(Color(UIColor.systemGray6))
                                                    .cornerRadius(4)
                                                Text("AAAA")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("1 share")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("$0.00")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("-$0.00")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        
                                        // History Item 3
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Buy")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .padding(4)
                                                    .background(Color(UIColor.systemGray6))
                                                    .cornerRadius(4)
                                                Text("AAAA")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("1 share")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("$0.00")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("+$0.00")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Divider Between Date Groups
                                Divider()
                                    .padding(.horizontal)
                                
                                // Second Date Group
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("December 18, 2023")
                                        .font(Font.custom("Anuphan-Bold", size: 16))
                                    
                                    VStack(spacing: 12) {
                                        // Add additional history items here if needed
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Buy")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .padding(4)
                                                    .background(Color(UIColor.systemGray6))
                                                    .cornerRadius(4)
                                                Text("AAAA")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("1 share")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("$0.00")
                                                    .font(Font.custom("Anuphan-Bold", size: 16))
                                                Text("+$0.00")
                                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }.onAppear{
                fetchUserData()
                fetchAllStockPrices()
            }
                .fullScreenCover(
                    isPresented: $isPresentingLink,
                    onDismiss: { isPresentingLink = false },
                    content: {
                        if let linkController {
                            linkController
                                .ignoresSafeArea(.all)
                        } else {
                            Text("Error: LinkController not initialized")
                        }
                    }
                )
            
            
            // Trade Button
            Button(action: {
                // Trade action
            }) {
                Text("Trade")
                    .font(Font.custom("Anuphan-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: 0x105A90))
                    .foregroundColor(.white)
                    .cornerRadius(50)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
    private func fetchUserData() {
        // Firebase Authentication to fetch the user's email
        guard let user = Auth.auth().currentUser else {
            print("No user signed in")
            return
        }

        self.email = user.email ?? ""
    }
    // Fetch prices for all stocks
    private func fetchAllStockPrices() {
        for stock in portfolio.stocks {
            fetchStockPrice(for: stock.ticker)
        }
    }
    // Fetch stock price for a single ticker
    private func fetchStockPrice(for ticker: String) {
        let url = URL(string: "https://app.finabl.org/api/stockData/quickStockData/\(ticker)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            
            do {
                // Decode the data into an array of dictionaries
                if let stockArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let stock = stockArray.first,
                   let price = stock["price"] as? Double {
                    DispatchQueue.main.async {
                        stockPrices[ticker] = price

                    }
                } else {
                    print("Failed to extract stock data from JSON")
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    private func fetchData() {
        guard let days = timeRangeMapping[selectedTimeRange] else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -days, to: today)!
        
        let fromDate = dateFormatter.string(from: pastDate)
        let toDate = dateFormatter.string(from: today)
        
        fmpAPI.fetchLineChartData(symbol: "AAPL", from: fromDate, to: toDate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.lineChartData = data
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    /*private func createHandler() -> Result<Handler, Plaid.CreateError> {
        let configuration = createLinkTokenConfiguration()

        // This only results in an error if the token is malformed.
        return Plaid.create(configuration)
    }*/
    private func initiateDeposit() {
        print(publicToken)
        guard let depositAmountDouble = Double(depositAmount) else {
            print("Invalid deposit amount")
            return
        }

        isTransferInProgress = true

        let url = URL(string: "https://app.finabl.org/api/portfolios/deposit")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "email": email,
            "plaidPublicToken": publicToken,
            "accountId": accountId,
            "amount": depositAmountDouble
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            isTransferInProgress = false
            guard error == nil, let data = data else {
                print("Error initiating deposit: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Deposit response: \(String(data: data, encoding: .utf8) ?? "")")
        }.resume()
    }

    /*private func createLinkTokenConfiguration() -> LinkTokenConfiguration {
        // Steps to acquire a Link Token:
        //
        // 1. Sign up for a Plaid account to get an API key.
        //      Ref - https://dashboard.plaid.com/signup
        // 2. Make a request to our API using your API key.
        //      Ref - https://plaid.com/docs/quickstart/#introduction
        //      Ref - https://plaid.com/docs/api/tokens/#linktokencreate

        let linkToken = "n0token4u"

        // In your production application replace the hardcoded linkToken above with code that fetches a linkToken
        // from your backend server which in turn retrieves it securely from Plaid, for details please refer to
        // https://plaid.com/docs/api/tokens/#linktokencreate


        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { success in
            // Closure is called when a user successfully links an Item. It should take a single LinkSuccess argument,
            // containing the publicToken String and a metadata of type SuccessMetadata.
            // Ref - https://plaid.com/docs/link/ios/#onsuccess
            print("Public Token: \(success.publicToken)")
            let accountId = success.metadata.accounts.first?.id ?? ""
            print("Account ID: \(accountId)")
            // Store these for initiating transfers
            UserDefaults.standard.set(success.publicToken, forKey: "PlaidPublicToken")
            UserDefaults.standard.set(accountId, forKey: "PlaidAccountId")
            print("public-token: \(success.publicToken) metadata: \(success.metadata)")
            isPresentingLink = false
        }


        // Optional closure is called when a user exits Link without successfully linking an Item,
        // or when an error occurs during Link initialization. It should take a single LinkExit argument,
        // containing an optional error and a metadata of type ExitMetadata.
        // Ref - https://plaid.com/docs/link/ios/#onexit
        linkConfiguration.onExit = { exit in
            if let error = exit.error {
                print("exit with \(error)\n\(exit.metadata)")
            } else {
                // User exited the flow without an error.
                print("exit with \(exit.metadata)")
            }
            isPresentingLink = false
        }

        // Optional closure is called when certain events in the Plaid Link flow have occurred, for example,
        // when the user selected an institution. This enables your application to gain further insight into
        // what is going on as the user goes through the Plaid Link flow.
        // Ref - https://plaid.com/docs/link/ios/#onevent
        linkConfiguration.onEvent = { event in
            print("Link Event: \(event)")
        }

        return linkConfiguration
    }*/
}



#Preview {
    AlpacaPortfolioSpecificView(portfolio: AlpacaPortfolio(
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
    ))
}

