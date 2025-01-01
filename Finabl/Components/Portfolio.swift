import Foundation

struct Portfolio: Identifiable, Decodable, Equatable {
    let id = UUID() // Generate a unique ID for each portfolio
    let portfolioName: String
    let generalExplanation: String
    let timeHorizon: String?
    let riskTolerance: String?
    let stocksETFs: [StockETF]

    struct StockETF: Identifiable, Decodable, Equatable {
        let id = UUID() // Generate a unique ID for each Stock/ETF
        let ticker: String
        let allocation: String
        let riskLevel: String
        let justification: String

        // Map JSON keys to Swift property names if necessary
        enum CodingKeys: String, CodingKey {
            case ticker
            case allocation
            case riskLevel = "risk_level"
            case justification
        }
    }

    // Map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case portfolioName = "portfolio_name"
        case generalExplanation = "general_explanation"
        case timeHorizon = "time_horizon"
        case riskTolerance = "risk_tolerance"
        case stocksETFs = "stocks_etfs"
    }

    // Conform to Equatable by comparing all properties
    static func == (lhs: Portfolio, rhs: Portfolio) -> Bool {
        return lhs.id == rhs.id &&
            lhs.portfolioName == rhs.portfolioName &&
            lhs.generalExplanation == rhs.generalExplanation &&
            lhs.timeHorizon == rhs.timeHorizon &&
            lhs.riskTolerance == rhs.riskTolerance &&
            lhs.stocksETFs == rhs.stocksETFs
    }
}
