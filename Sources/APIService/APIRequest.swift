import Foundation

protocol APIRequest {
    associatedtype ReturnType: Decodable
    
    // Почитать про структуру ссылки!!!
    var scheme: URLScheme { get }
    var path: String { get }
    var method: HTTPMethod  { get }
    var contentType: String { get }
    
    func asURLRequest(for config: APIConfiguration, with option: QueryItemOption) -> URLRequest?
    func createQueryItems() -> [URLQueryItem]
    func createBody() -> Data?
}

// MARK: - APIRequest Default Property Implementations
extension APIRequest {
    var scheme: URLScheme {
        .https
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var contentType: String {
        "application/json"
    }
}

// MARK: - APIRequest Default Methods Implementations
extension APIRequest {
    func asURLRequest(for config: APIConfiguration, with option: QueryItemOption) -> URLRequest? {
        var components = URLComponents()
        components.scheme = config.scheme.rawValue // зачем схема и в конфиге и в реквесте???
        components.host = config.host
        components.port = config.port
        components.path = config.path + path // зачем путь и тут и там???
        
        var queryItems = [URLQueryItem(name: "apikey", value: config.apiKey)]
        queryItems.append(contentsOf: createQueryItems())
        queryItems.append(contentsOf: option.queryItems)
        components.queryItems = queryItems.isEmpty ? nil : queryItems // добавлять проверку на пустой масив или нет???
        
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

struct QueryItemOption {
    let queryItems: [URLQueryItem]
    
    init(_ queryItems: [URLQueryItem]) {
        self.queryItems = queryItems
    }
    
    static let none = QueryItemOption([])
    
    static func with(parameters: [String: String]) -> QueryItemOption {
        let items = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        return QueryItemOption(items)
    }
}

enum URLScheme: String {
    case https
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
