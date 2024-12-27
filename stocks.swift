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
