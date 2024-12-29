enum PolygonTimespan: String {
    case second = "second"
    case minute = "minute"
    case hours = "hour"
    case days = "day"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
}

struct PolygonSort {
    static let asc = "asc"
    static let desc = "desc"
}

struct HTTP {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func get(_ path: String) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: URL(string: path+apiKey)!)
    }
}
