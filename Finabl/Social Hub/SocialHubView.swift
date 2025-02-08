import SwiftUI
import FirebaseAuth

struct SocialHubView: View {
    @State private var isLoading: Bool = true
    @State private var displayName: String = "Displayname"
    @State private var username: String = "@username"
    @State private var friendsCount: Int = 0
    @State private var achievements: [String] = ["achievement", "achievement", "achievement", "achievement"]
    @State private var isSignedIn: Bool = false
    @State private var userEmail: String? = nil
    @State private var isSettingsActive: Bool = false
    @State private var showSignInView: Bool = false
    @State private var showSignUpView: Bool = false
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if !isSignedIn {
                    // User not signed in
                    VStack(spacing: 16) {
                        Text("You aren't signed in :(")
                            .font(Font.custom("Anuphan-Bold", size: 20))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            // Navigate to SignInView
                            showSignInView.toggle()
                        }) {
                            Text("Sign In")
                                .font(Font.custom("Anuphan-Medium", size: 16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }.sheet(isPresented: $showSignInView) {
                            SignInView(isSignedIn: $isSignedIn)
                        }
                        
                        Button(action: {
                            // Navigate to SignUpView
                            showSignUpView.toggle()
                        }) {
                            Text("Sign Up")
                                .font(Font.custom("Anuphan-Medium", size: 16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }.sheet(isPresented: $showSignUpView) {
                        OnboardingView(isSignedIn: $isSignedIn)
                    }
                    .padding()
                } else {
                    // User signed in
                    VStack {
                        // Top Navigation Bar
                        HStack {
                            Image("elephant head")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text(username)
                                .font(Font.custom("Anuphan-Medium", size: 18))
                                .foregroundColor(.primary)
                            Spacer()
                            Button(action: {
                                isSettingsActive.toggle() // Open Settings
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            .sheet(isPresented: $isSettingsActive) {
                                SettingsView(isSignedIn: $isSignedIn) // Pass the binding to track sign-out
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        ScrollView {
                            // Profile Info Section
                            VStack(spacing: 8) {
                                Image("defaultpfp")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                /*Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80) // Placeholder for profile image
                                */
                                Text(displayName)
                                    .font(Font.custom("Anuphan-Medium", size: 24))
                                    .foregroundColor(.primary)
                                
                                Text(username)
                                    .font(Font.custom("Anuphan-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                
                                Text("\(friendsCount) friends")
                                    .font(Font.custom("Anuphan-Regular", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            Button(action: {
                                // Edit Profile action
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .font(.body)
                                    Text("Edit Profile")
                                        .font(Font.custom("Anuphan-Light", size: 16))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            // Buttons Section

                            HStack(spacing: 15) {
                                NavigationLink(destination: MessagesView().navigationBarBackButtonHidden()) {
                                    VStack {
                                        Image(systemName: "message.fill")
                                            .font(.system(size: 24))
                                        Text("Messages")
                                            .font(Font.custom("Anuphan-Medium", size: 13))
                                    }
                                    .frame(height: 75)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    
                                }
                                NavigationLink(destination: AlpacaPortfolioListView(titleToUse: "Collaborative Portfolios", portfolios: portfolios).navigationBarBackButtonHidden()) {
                                    VStack {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 24))
                                        Text("Collaborative\nportfolios")
                                            .font(Font.custom("Anuphan-Medium", size: 13))
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(height: 75)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                
                                NavigationLink(destination: CompetitionsView().navigationBarBackButtonHidden()) {
                                    VStack {
                                        Image(systemName: "trophy.fill")
                                            .font(.system(size: 24))
                                        Text("Competition")
                                            .font(Font.custom("Anuphan-Medium", size: 13))
                                    }
                                    .frame(height: 75)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                            .padding([.horizontal, .top, .bottom])
                            
                            // Overview Section
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Overview")
                                    .font(Font.custom("Anuphan-Bold", size: 18))
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                    ForEach(achievements, id: \.self) { achievement in
                                        VStack {
                                            Text("5")
                                                .font(Font.custom("Anuphan-Bold", size: 24))
                                            Text(achievement)
                                                .font(Font.custom("Anuphan-Regular", size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 80)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                    }
                }
            }
        }

        .onAppear {
            checkFirebaseAuth()
        }
    }
    
    private func checkFirebaseAuth() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email
            isSignedIn = true
            fetchUserData()
            fetchPortfolios(email: userEmail!)
        } else {
            isSignedIn = false
            isLoading = false
        }
    }
    
    private func fetchUserData() {
        guard let email = userEmail else {
            print("No email available for fetching user data")
            isLoading = false
            return
        }
        
        guard let url = URL(string: "https://app.finabl.org/api/users/user/\(email)") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            guard let data = data else {
                print("No data received")
                isLoading = false
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.displayName = "\(json["firstName"] ?? "") \(json["lastName"] ?? "")"
                        self.username = "@\(json["userName"] ?? "username")"
                        self.friendsCount = (json["friends"] as? Int) ?? 0
                        self.achievements = (json["achievements"] as? [String]) ?? ["achievement"]
                        self.isLoading = false
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                isLoading = false
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
    
}


#Preview {
    SocialHubView()
}
