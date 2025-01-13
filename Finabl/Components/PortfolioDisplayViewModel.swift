//
//  PortfolioDisplayViewModel.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/31/24.
//

import Foundation

class PortfolioDisplayViewModel: ObservableObject {
    @Published var portfolios: [Portfolio] = [] // Portfolios to display
    @Published var hasFinishedLoading: Bool = false // Tracks if all portfolios have been loaded

    init() {}

    // Custom initializer for previews or mock data
    init(portfolios: [Portfolio]) {
        self.portfolios = portfolios
        self.hasFinishedLoading = true
    }

    // Fetch portfolios one by one
    func fetchPortfolios() {
        guard let url = URL(string: "https://app.finabl.org/api/generate-portfolios") else {
            print("Invalid URL")
            return
        }

        // Simulating delayed API responses for each portfolio
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching portfolios: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let portfoliosResponse = try JSONDecoder().decode([Portfolio].self, from: data)
                DispatchQueue.main.async {
                    for portfolio in portfoliosResponse {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Simulate delay
                            self.portfolios.append(portfolio)
                        }
                    }
                    self.hasFinishedLoading = true
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    func addPortfolio(_ portfolioResponse: [String: Any]) {
        // Extract portfolios from the top-level key
        guard let portfoliosArray = portfolioResponse["portfolios"] as? [[String: Any]] else {
            print("Error: 'portfolios' key not found or not an array.")
            return
        }

        for portfolio in portfoliosArray {
            do {
                let portfolioData = try JSONSerialization.data(withJSONObject: portfolio, options: [])
                let newPortfolio = try JSONDecoder().decode(Portfolio.self, from: portfolioData)
                portfolios.append(newPortfolio)
            } catch {
                print("Error converting portfolio: \(error)")
            }
        }
    }


}
