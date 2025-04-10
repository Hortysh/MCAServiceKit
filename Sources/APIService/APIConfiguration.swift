import Foundation

struct APIConfiguration {
    let scheme: URLScheme
    let host: String
    let path: String
    let port: Int?
    let apiKey: String
    let securityPolicy: SecurityPolicy
}

// Почему я могу сделать static stored property в extension???
extension APIConfiguration {
    static let newsAPI = APIConfiguration(
        scheme: .https,
        host: "newsapi.org",
        path: "",
        port: nil,
        apiKey: "c4273f93c3f24a6ab28e8a852a7f44b1",
        securityPolicy: .sslPinning(publicKeyHash: "yXb31MO6EiY6g4o/D0GVNLFxH5MOR6BOa/ojJkmYt9w=")
    )
}

enum SecurityPolicy: Equatable {
    case none
    case sslPinning(publicKeyHash: String)
}
