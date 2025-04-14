import Foundation

public struct APIConfiguration: Sendable {
    public let scheme: URLScheme
    public let host: String
    public let path: String
    public let port: Int?
    public let apiKey: String
    public let securityPolicy: SecurityPolicy
    
    public init(scheme: URLScheme, host: String, path: String, port: Int?, apiKey: String, securityPolicy: SecurityPolicy) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.port = port
        self.apiKey = apiKey
        self.securityPolicy = securityPolicy
    }
}

// Почему я могу сделать static stored property в extension???
public extension APIConfiguration {
    static let newsAPI = APIConfiguration(
        scheme: .https,
        host: "newsapi.org",
        path: "",
        port: nil,
        apiKey: "c4273f93c3f24a6ab28e8a852a7f44b1",
        securityPolicy: .sslPinning(publicKeyHash: "yXb31MO6EiY6g4o/D0GVNLFxH5MOR6BOa/ojJkmYt9w=")
    )
}

public enum SecurityPolicy: Equatable, Sendable {
    case none
    case sslPinning(publicKeyHash: String)
}
