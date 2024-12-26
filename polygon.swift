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
    
    init (apiKey: String) {
        self.apiKey = apiKey
    }
    
    func aggregates(ticker: String, multiplier: Int, timespan: String, from: String, to: String, adjusted: Bool = true, sort: String = "asc", limit: Int = 5000) async throws -> (Data, URLResponse) {
        let aggs = Aggregates(ticker: ticker, multiplier: multiplier, timespan: timespan, from: from, to: to, adjusted: adjusted, sort: sort, limit: limit)
        return try await HTTP.get("\(aggs.url)\(apiKey)")
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
         "https://api.polygon.io/v2/aggs/ticker/\(ticker)/range/\(multiplier)/day/\(from)/\(to)?adjusted=\(adjusted)&sort=\(sort)&apiKey="
    }
}

struct GroupedBars: Path {
    private let date: String
    private let adjusted = true
    private let includeOTC = false
    
    var url: String {
        "https://api.polygon.io/v2/aggs/grouped/locale/us/market/stocks/\(date)?adjusted=\(adjusted)&include_otc=\(false)&apiKey="
    }
}

struct DailyOpenClose: Path {
    private let ticker: String
    private let date: String
    private var adjusted = true
    
    init(ticker: String, date: String, adjusted: Bool = true) {
        self.ticker = ticker
        self.date = date
        self.adjusted = adjusted
    }
    
    var url: String {
        "https://api.polygon.io/v2/aggs/daily/\(date)/\(ticker)?adjusted=\(adjusted)&apiKey="
    }
}

struct PreviousClose: Path {
    private let ticker: String
    private var adjusted = true
    
    init(ticker: String, adjusted: Bool = true) {
        self.ticker = ticker
        self.adjusted = adjusted
    }

    var url: String {
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/prev?adjusted=\(adjusted)&apiKey="
    }
}

struct Trades: Path {
    private let ticker: String
    private var timestamp: String?
    private var order: String?
    private var limit = 1000
    
    
    var url: String {
        "https://api.polygon.io/v2/aggs/ticker/\(ticker)/trades?apiKey="
    }
}



//Responses

struct AggregatesResponse: Codable {
    let resultsCount: Int
    let results: [Results]
    
    struct Results: Codable {
        let o: Double
        let h: Double
        let l: Double
        let c: Double
        let n: Int
        let v: Int
        let vw: Double
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

let polygon = Polygon(apiKey: apiKey)
do {
    let (data, response) = try await polygon.stocks.aggregates(ticker: "AAPL",
                                                               multiplier: 1,
                                                               timespan: PolygonTimespan.day,
                                                               from: "2023-02-09",
                                                               to: "2023-02-10")


    let aggs = try JSONDecoder().decode(AggregatesResponse.self, from: data)
    for result in aggs.results {
        print(result)
    }
} catch let error {
    print(error)
}

