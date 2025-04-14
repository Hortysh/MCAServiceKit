import Foundation
import Combine
import CommonCrypto

@available(iOS 15, macOS 13, *)
public protocol APIFetching {
    func fetch<R: APIRequest>(_ request: R) -> AnyPublisher<R.ReturnType, Error>
    func fetch<R: APIRequest>(_ request: R, with options: QueryItemOption) -> AnyPublisher<R.ReturnType, Error>
}

public final class APIClient: NSObject {
    public let config: APIConfiguration
    
    public init(config: APIConfiguration = .newsAPI) {
        self.config = config
    }
}

@available(iOS 15, macOS 13, *)
extension APIClient: APIFetching {
    public func fetch<R: APIRequest>(_ request: R) -> AnyPublisher<R.ReturnType, Error> {
        fetch(request, with: .none)
    }
    
    public func fetch<R: APIRequest>(_ request: R, with options: QueryItemOption) -> AnyPublisher<R.ReturnType, Error> {
        guard let urlRequest = request.asURLRequest(for: config, with: options) else {
            print("❌ URLRequest failed! Не удалось сформировать URL-запрос ")
            let error = APIError.badRequest(description: "Не удалось сформировать URL-запрос")
            
            return Fail(outputType: R.ReturnType.self, failure: error).eraseToAnyPublisher()
        }
        
        let urlSession = createURLSession(delegate: self)
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .mapError { urlError in
                print("❌ Сетевая ошибка при выполнении запроса")
                let error = APIError.networkFailure(urlError)
                return error
            }
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    print("❌ Получен неверный тип ответа от сервера")
                    let error = APIError.invalidResponse
                    throw error
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Получен некорректный код состояния: \(httpResponse.statusCode)")
                    let error = APIError.serverError(
                        statusCode: httpResponse.statusCode,
                        description: "Ошибка сервера",
                        responseData: result.data
                    )
                    throw error
                }
                
                return result.data
            }
            .decode(type: R.ReturnType.self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    print("Ошибка декодирования ответа сервера")
                    return APIError.decodingError(description: decodingError.localizedDescription)
                } else {
                    print("Неизвестная ошибка при декодировании")
                    return APIError.unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension APIClient: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard config.securityPolicy != .none else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let certificate = certificates.first else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let serverCertificateData = SecCertificateCopyData(certificate) as Data
        let hash = sha256(data: serverCertificateData)
        
        if case let SecurityPolicy.sslPinning(publicKeyHash: pinnedHash) = config.securityPolicy, hash == pinnedHash {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            print("❌ SSL Pinning failed! Сертификат не совпадает.")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

private extension APIClient {
    func createURLSession(delegate: URLSessionDelegate?) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        let urlSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        
        return urlSession
    }
    
    func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
}
