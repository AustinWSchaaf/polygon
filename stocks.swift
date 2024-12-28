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
        let (data, response) = try await http.get(aggs.url)
        return try PolygonDecoder().decode(AggregatesResponse.self, from: data)
    }
    
    func groupedBars(date: String, adjusted: Bool = true, includeOTC: Bool = false) async throws -> GroupedBarsResponse {
        let groupedBars = GroupedBars(date: date, adjusted: adjusted, includeOTC: includeOTC)
        let (data, response) = try await http.get(groupedBars.url)
        return try PolygonDecoder().decode(GroupedBarsResponse.self, from: data)
    }
    
    func dailyOpenClose(ticker: String, date: String, adjusted: Bool = false) async throws -> DailyOpenCloseResponse {
        let dailyOpenClose = DailyOpenClose(ticker: ticker, date: date, adjusted: adjusted)
        let (data, response) = try await http.get(dailyOpenClose.url)
        return try PolygonDecoder().decode(DailyOpenCloseResponse.self, from: data)
    }
}
