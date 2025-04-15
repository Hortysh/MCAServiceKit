import Foundation

public protocol APIRequest {
    associatedtype ReturnType: Decodable
    
    var path: String { get }
    var method: HTTPMethod  { get }
    var contentType: String { get }
    
    func asURLRequest(for config: APIConfiguration, with option: QueryItemOption) -> URLRequest?
    func createQueryItems() -> [URLQueryItem]
    func createBody() -> Data?
}

// MARK: - APIRequest Default Property Implementations
public extension APIRequest {
    var method: HTTPMethod {
        .get
    }
    
    var contentType: String {
        "application/json"
    }
}

// MARK: - APIRequest Default Methods Implementations
public extension APIRequest {
    func asURLRequest(for config: APIConfiguration, with option: QueryItemOption) -> URLRequest? {
        var components = URLComponents()
        components.scheme = config.scheme.rawValue
        components.host = config.host
        components.port = config.port
        components.path = config.path + path
        
        var queryItems = [URLQueryItem(name: "apikey", value: config.apiKey)]
        queryItems.append(contentsOf: createQueryItems())
        queryItems.append(contentsOf: option.queryItems)
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = createBody()
        
        return request
    }
    
    func createQueryItems() -> [URLQueryItem] {
        return []
    }
    
    func createBody() -> Data? {
        return nil
    }
}

public struct QueryItemOption : Sendable {
    public let queryItems: [URLQueryItem]
    
    private init(_ queryItems: [URLQueryItem]) {
        self.queryItems = queryItems
    }
    
    public static let none = QueryItemOption([])
    
    public static func with(parameters: [String: String]) -> QueryItemOption {
        let items = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        return QueryItemOption(items)
    }
}

public enum URLScheme: String, Sendable {
    case https
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
