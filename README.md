# Swift Polygon Client

## Stock endpoint example
```swift
let apiKey = "YOUR_API_KEY"
let polygon = Polygon(apiKey: apiKey)

do {
  let aggs = try await polygon.stocks.aggregates(ticker: "AAPL",
                                                 multiplier: 1,
                                                 timespan: PolygonTimespan.minute,
                                                 from: "2023-02-09",
                                                 to: "2023-02-10")
  for result in aggs.results {
    print(result)
  }
} catch(let error) {
  print(error)
}
```


