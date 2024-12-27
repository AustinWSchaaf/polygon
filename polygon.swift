//
//  Polygon.swift
//  Polygon
//
//  Created by Austin Schaaf on 12/25/24.
//

import Foundation


//Main

struct Polygon: Sendable {
    private let apiKey: String
    let stocks: Stocks
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.stocks = Stocks(apiKey: apiKey)
    }
    
}

//Security Types

struct Stocks {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func aggregates(ticker: String, multiplier: Int, timespan: String, from: String, to: String, adjusted: Bool = true, sort: String = "asc", limit: Int = 5000) async throws -> (Data, URLResponse) {
        let aggs = Aggregates(ticker: ticker, multiplier: multiplier, timespan: timespan, from: from, to: to, adjusted: adjusted, sort: sort, limit: limit)
        print(aggs.url)
        return try await HTTP.get("\(aggs.url)\(apiKey)")
    }
    
    func groupedBars(date: String, adjusted: Bool = true, includeOTC: Bool = false) async throws -> (Data, URLResponse) {
        let groupedBars = GroupedBars(date: date, adjusted: adjusted, includeOTC: includeOTC)
        return try await HTTP.get("\(groupedBars.url)\(apiKey)")
    }
}


//Market Data Endpoints
/*
//stocks
 /v2/aggs/ticker/{stocksTicker}/range/{multiplier}/{timespan}/{from}/{to}
 
//options
 /v2/aggs/ticker/{optionsTicker}/range/{multiplier}/{timespan}/{from}/{to}
 
//indices
 /v2/aggs/ticker/{indicesTicker}/range/{multiplier}/{timespan}/{from}/{to}
 
//forex
 /v2/aggs/ticker/{forexTicker}/range/{multiplier}/{timespan}/{from}/{to}

//crypto
 /v2/aggs/ticker/{cryptoTicker}/range/{multiplier}/{timespan}/{from}/{to}
 
*/

struct Aggregates: Path {
    private let ticker: String
    private let multiplier: Int
    private let timespan: String
    private let from: String
    private let to: String
    private var adjusted = true
    private var sort = "asc"
    private var limit = 5000
    
    init(ticker: String, multiplier: Int, timespan: String, from: String, to: String, adjusted: Bool = true, sort: String = "asc", limit: Int = 5000) {
        self.ticker = ticker
        self.multiplier = multiplier
        self.timespan = timespan
        self.from = from
        self.to = to
        self.adjusted = adjusted
        self.sort = sort
        self.limit = limit
    }
    
    var url: String {
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/range/\(multiplier)/\(timespan)/\(from)/\(to)?adjusted=\(adjusted)&sort=\(sort)&apiKey="
    }
}

struct GroupedBars: Path {
    private let date: String
    private var adjusted = true
    private var includeOTC = false
    
    init(date: String, adjusted: Bool = true, includeOTC: Bool = false) {
        self.date = date
        self.adjusted = adjusted
        self.includeOTC = includeOTC
    }
    
    var url: String {
        "https://api.polygon.io/v2/aggs/grouped/locale/us/market/stocks/\(date)?adjusted=\(adjusted)&include_otc=\(false)&apiKey="
    }
}

struct DailyOpenClose: Path {
    private let ticker: String
    private let date: String
    private var adjusted = true
    
    var url: String {
        "https://api.polygon.io/v2/aggs/daily/\(date)/\(ticker)?adjusted=\(adjusted)&apiKey="
    }
}

struct PreviousClose: Path {
    private let ticker: String
    private var adjusted = true

    var url: String {
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/prev?adjusted=\(adjusted)&apiKey="
    }
}

//struct Trades: Path {
//    private let ticker: String
//    private var timestamp: PolygonDate?
//    private var order: String?
//    private var limit = 1000
//    private var sort: String?
//    
//}

struct LastTrade: Path {
    private let ticker: String
    
    var url: String {
        "https://api.polygon.io/v2/last/trade/\(ticker)?apiKey="
    }
}

struct Quotes: Path {
    private let ticker: String
    private var timestamp: String?
    private var order: String?
    private var limit: Int = 1000
    private var sort: String?
    
    var url: String {
        "https://api.polygon.io/v3/quotes/\(ticker)?order=asc&limit=1000&sort=timestamp&apiKey="
    }
}

//protocols

protocol Path {
    var url: String { get }
}

//Helpers

struct PolygonTimespan {
    static let second = "second"
    static let minute = "minute"
    static let hour = "hour"
    static let day = "day"
    static let month = "month"
    static let quarter = "quarter"
    static let year = "year"
}

struct PolygonSort {
    static let asc = "asc"
    static let desc = "desc"
}

struct HTTP {
    static func get(_ path: String) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: URL(string: path)!)
    }
}

enum PolygonTime {
    case date(String)
    case timestamp(Int)
    
    func rawValue() -> String {
        switch self {
        case .date(let date):
            return date
        case .timestamp(let timestamp):
            return String(timestamp)
        }
    }
}

class PolygonDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}

extension PolygonDecoder: @unchecked Sendable {
    
}

//Responses

struct BarData: Codable {
    let T: String?
    let o: Double
    let h: Double
    let l: Double
    let c: Double
    let t: Int
    let n: Int
    let v: Int
    let vw: Double
}

struct AggregatesResponse: Codable {
    let adjusted: Bool
    let nextUrl: String?
    let queryCount: Int
    let requestId: String
    let results: [BarData]
    let resultsCount: Int
    let status: String
    let ticker: String
}

struct GroupedBarsResponse: Codable {
    let adjusted: Bool
    let queryCount: Int
    let results: [BarData]
    let resultsCount: Int
    let status: String
}

struct DailyOpenCloseResponse: Codable {
    let afterHours: Double
    let close: Double
    let from: String
    let high: Double
    let low: Double
    let open: Double
    let premarket: Double
    let status: String
    let symbol: String
    let volume: Int
}

struct PreviousCloseResponse: Codable {
    let adjusted: Bool
    let queryCount: Int
    let requestId: String
    let results: [BarData]
    let resultsCount: Int
    let status: String
    let ticker: String
}

let apiKey = ""
let polygon = Polygon(apiKey: apiKey)
do {
    let (data, _) = try await polygon.stocks.aggregates(ticker: "AAPL",
                                                               multiplier: 1,
                                                               timespan: PolygonTimespan.minute,
                                                               from: "2023-02-09",
                                                               to: "2023-02-13")


    let aggs = try PolygonDecoder().decode(AggregatesResponse.self, from: data)
    print(aggs.resultsCount)
} catch let error {
    print(error)
}

