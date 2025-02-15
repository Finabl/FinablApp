//
//  HomeView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 1/1/25.
//

import SwiftUI
import FirebaseAuth

struct Watchlist: Codable, Identifiable {
    var id: String
    var name: String
    var tickers: [String]
}

struct WatchlistResponse: Codable {
    let watchlists: [Watchlist]
}

struct HomeView: View {
    @State private var firstName: String = "Gursharan"
    @State private var stockPrice: String = "$0.00"
    @State private var userEmail: String = ""
    @State private var lineChartData: [Candlestick] = []
    @State private var isLoading = true
    @State private var goals: [Goal] = []
    @State private var showCreateGoalPopup = false // 🔥 State to show/hide popup
    @State private var watchlists: [Watchlist] = []
    private let fmpAPI = FMPAPI()
    let apiBaseUrl = "https://app.finabl.org/api/goals"
    private let timeRangeMapping: [String: Int] = [
        "1D": 1,
        "5D": 5,
        "1M": 30,
        "3M": 90,
        "1Y": 365,
        "3Y": 1095,
        "Max": 1825
    ]
    @State private var selectedTimeRange: String = "1D"
    @State private var titleToUseForPortfolios: String = "Portfolios"
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
            HStack {
                Spacer()
                NavigationLink(destination: NotifView().navigationBarBackButtonHidden()) {
                    ZStack {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color(hex: 0xF7F7F7))
                        Image("notif")
                            .resizable()
                            .foregroundStyle(Color(hex: 0x656D72))
                            .frame(width: 25, height: 25)
                    }
                }
                NavigationLink(destination: WalletView().navigationBarBackButtonHidden()) {
                    ZStack {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color(hex: 0xF7F7F7))
                        Image("wallet")
                            .resizable()
                            .foregroundStyle(Color(hex: 0x656D72))
                            .frame(width: 25, height: 25)
                    }
                }
            }
            .padding([.horizontal, .bottom])
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
                        Text("+ \(stockPrice)")
                            .font(Font.custom("Anuphan-Medium", size: 24))
                        ProgressView(value: 0.3)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(greenColor)))
                            .cornerRadius(10)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                }
                .padding(.horizontal)
                VStack {
                    if isLoading {
                        Text("Loading data...")
                            .onAppear {
                                fetchData()
                                fetchStockData()
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

                    
                }.padding()
                // Portfolios Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Portfolios")
                            .font(Font.custom("Anuphan-Bold", size: 18))
                        Spacer()
                        if !portfolios.isEmpty {
                            NavigationLink(destination: AlpacaPortfolioListView(titleToUse: titleToUseForPortfolios,portfolios: portfolios).navigationBarBackButtonHidden(true)) {
                                Text("See all")
                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                    .foregroundColor(.blue)
                            }
                        }

                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            if portfolios.isEmpty {
                                VStack(alignment: .center) {
                                    Text("You have no portfolios!")
                                        .foregroundStyle(.secondary)
                                        .font(Font.custom("Anuphan-Bold", size: 16))
                                    NavigationLink(destination: PortfolioGenerationView()) {
                                        Text("Create One Now")
                                            .font(Font.custom("Anuphan-Medium", size: 14))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        
                                    }.padding(.bottom)

                                }
                                

                            } else {
                                ForEach(portfolios) { portfolio in
                                    
                                    NavigationLink(destination: AlpacaPortfolioSpecificView(portfolio: portfolio).navigationBarBackButtonHidden()) {
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
                            showCreateGoalPopup.toggle()
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                    ForEach(goals.indices, id: \.self) { goalIndex in
                        let goal = goals[goalIndex] // ✅ Get the goal

                        NavigationLink(destination: GoalSummaryView(
                                               goals: $goals,
                                               goal: goal,
                                               userEmail: userEmail,
                                               deleteGoal: deleteGoal,
                                               markTaskComplete: markTaskComplete
                        )) {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(goals[goalIndex].title)
                                        .font(Font.custom("Anuphan-Regular", size: 16))
                                    Spacer()
                                    Text("\(goals[goalIndex].progress)%")
                                        .font(Font.custom("Anuphan-Regular", size: 14))
                                        .foregroundColor(.gray)
                                }
                                ProgressView(value: Double(goals[goalIndex].progress) / 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: greenColor))
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                            }
                            
                        }

                        .swipeActions(edge: .trailing, allowsFullSwipe: true) { // 🔥 Add swipe action
                            Button(role: .destructive) {
                                deleteGoal(goalId: goals[goalIndex].id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red) // 🔥 Matches UI from your image
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
                    ForEach(watchlists, id: \.id) { watchlist in
                        NavigationLink(destination: WatchlistSummaryView(watchlist: watchlist, userEmail: userEmail)) {
                            HStack {
                                Text(watchlist.name)
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
        .sheet(isPresented: $showCreateGoalPopup) { // 🔥 Present the popup
            GoalCreationView(isPresented: $showCreateGoalPopup, userEmail: userEmail, fetchGoals: {fetchGoals(userEmail: userEmail)})
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
        userEmail = email
        // Fetch user details
        fetchWatchlists(userEmail: email)
        fetchFirstName(email: email)
        fetchPortfolios(email: email)
        fetchGoals(userEmail: email)
    }
    private func fetchGoals(userEmail: String) {
        guard let url = URL(string: "\(apiBaseUrl)/get/\(userEmail)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, !data.isEmpty else {
                print("Error: API returned an empty response")
                return
            }
            
            do {
                // Convert raw data into a JSON object
                if let rawJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Raw API Response:", rawJson)
                    
                    // Extract "goals" array, but ensure it's a proper Swift array
                    if let goalsArray = rawJson["goals"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: goalsArray, options: [])
                        let decodedGoals = try JSONDecoder().decode([Goal].self, from: jsonData)
                        DispatchQueue.main.async {
                            self.goals = decodedGoals
                        }
                    } else {
                        print("Error: 'goals' key is not returning a valid array")
                    }
                } else {
                    print("Error: API did not return valid JSON")
                }
            } catch {
                print("Error decoding goals:", error)
            }
        }.resume()
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
                self.portfolios = []
                print("Error decoding portfolio JSON: \(error)")
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
    func fetchStockData() {
        let url = URL(string: "https://app.finabl.org/api/stockData/detailedStockData/AAPL")!
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
                   let price = stock["price"] as? Double, let description = stock["description"] as? String {
                    print("Stock data decoded: \(stock)")
                    DispatchQueue.main.async {
                        self.stockPrice = String(format: "$%.2f", price)
                        print("Updated stock price: \(self.stockPrice)")
                    }
                } else {
                    print("Failed to extract stock data from JSON")
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    /// Fetch watchlists from API
    func fetchWatchlists(userEmail: String) {
        guard let url = URL(string: "https://app.finabl.org/api/users/user/\(userEmail)/watchlists") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(WatchlistResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.watchlists = decodedResponse.watchlists
                    }
                } catch {
                    print("Failed to decode watchlists:", error)
                }
            }
        }.resume()
    }
    // Delete Goal
    private func deleteGoal(goalId: String) {
        guard let url = URL(string: "\(apiBaseUrl)/delete") else { return }
        
        let requestData: [String: Any] = [
            "email": userEmail,
            "goalId": goalId  // ✅ Send goalId instead of goalIndex
        ]
        
        print("📤 Deleting Goal:", requestData)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData) else {
            print("❌ JSON Serialization failed for deleteGoal()")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error deleting goal:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📩 Delete Goal Response Code:", httpResponse.statusCode)
            }
            
            if let data = data {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✅ Delete Goal Response:", responseJSON)
                    DispatchQueue.main.async {
                        fetchGoals(userEmail: userEmail)  // Refresh UI after deleting a goal
                    }
                } catch {
                    print("❌ Error decoding delete goal response:", error)
                }
            }
        }.resume()
    }
    // ✅ Add `markTaskComplete` function to avoid the error
    func markTaskComplete(goalId: String, taskIndex: Int) {
        guard let url = URL(string: "\(apiBaseUrl)/complete") else { return }

        let requestData: [String: Any] = [
            "email": userEmail,
            "goalId": goalId,
            "taskIndex": taskIndex
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async {
                        fetchGoals(userEmail: userEmail) // ✅ Refresh the goals list
                    }
                } catch {
                    print("❌ Error updating task:", error)
                }
            }
        }.resume()
    }
    
}

struct GoalCreationView: View {
    @Binding var isPresented: Bool // Controls modal visibility
    var userEmail: String
    var fetchGoals: () -> Void // Callback to refresh goals after creation

    @State private var newGoalTitle: String = ""
    @State private var newTaskTitle: String = ""
    @State private var goaltasks: [GoalTask] = []

    let apiBaseUrl = "https://app.finabl.org/api/goals"

    var body: some View {
        VStack {
            Text("Create New Goal")
                .font(.headline)
                .padding()

            TextField("Enter Goal Title", text: $newGoalTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                TextField("Enter Task", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add Task") {
                    if !newTaskTitle.isEmpty {
                        goaltasks.append(GoalTask(name: newTaskTitle, completed: false))
                        newTaskTitle = ""
                    }
                }
            }
            .padding()

            List {
                ForEach(goaltasks) { goaltask in
                    Text(goaltask.name)
                }
            }
            .frame(height: 100)

            Button("Create Goal") {
                createGoal()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Cancel") {
                isPresented = false // 🔥 Close modal
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding()
    }

    func createGoal() {
        guard let url = URL(string: "\(apiBaseUrl)/create") else { return }

        let goalData: [String: Any] = [
            "email": userEmail,
            "title": newGoalTitle,
            "description": "",
            "tasks": goaltasks.map { $0.name }
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: goalData) else {
            print("❌ JSON Serialization failed for createGoal()")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error creating goal:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📩 Create Goal Response Code:", httpResponse.statusCode)
            }

            if let data = data {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✅ Create Goal Response:", responseJSON)
                    DispatchQueue.main.async {
                        fetchGoals()  // 🔥 Refresh UI after creating goal
                        isPresented = false // 🔥 Close modal after successful creation
                    }
                } catch {
                    print("❌ Error decoding create goal response:", error)
                }
            }
        }.resume()
    }
    


}



#Preview {
    HomeView()
}
