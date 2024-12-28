struct Stocks {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func aggregates(ticker: String, multiplier: Int, timespan: String, from: String, to: String, adjusted: Bool = true,sort: String = "asc", limit: Int = 5000) async throws -> AggregatesResponse {
        let aggs = Aggregates(ticker: ticker,
                              multiplier: multiplier,
                              timespan: timespan,
                              from: from,
                              to: to,
                              adjusted: adjusted,
                              sort: sort, limit: limit)
        return try await data(type: .aggregates(aggs)) as! AggregatesResponse
    }
    
    func groupedBars(date: String, adjusted: Bool = true, includeOTC: Bool = false) async throws -> GroupedBarsResponse {
        let groupedBars = GroupedBars(date: date, adjusted: adjusted, includeOTC: includeOTC)
        return try await data(type: .groupedBars(groupedBars)) as! GroupedBarsResponse
    }
    
    func dailyOpenClose(ticker: String, date: String, adjusted: Bool = false) async throws -> DailyOpenCloseResponse {
        let dailyOpenClose = DailyOpenClose(ticker: ticker, date: date, adjusted: adjusted)
        return try await data(type: .dailyOpenClose(dailyOpenClose)) as! DailyOpenCloseResponse
    }
    
    
    enum StockReponseTypes {
        case aggregates(Aggregates)
        case groupedBars(GroupedBars)
        case dailyOpenClose(DailyOpenClose)
    }
    
    func data(type: StockReponseTypes) async throws -> PolygonResponse {
        switch type {
        case .aggregates(let aggs):
            let (data, response) = try await http.get(aggs.url)
            return try PolygonDecoder().decode(AggregatesResponse.self, from: data)
        case .groupedBars(let grouped):
            let (data, response) = try await http.get(grouped.url)
            return try PolygonDecoder().decode(GroupedBarsResponse.self, from: data)
        case .dailyOpenClose(let daily):
            let (data, response) = try await http.get(daily.url)
            return try PolygonDecoder().decode(DailyOpenCloseResponse.self, from: data)
        }
    }
}
