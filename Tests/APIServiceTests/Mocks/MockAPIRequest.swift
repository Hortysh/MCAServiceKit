import Foundation
import APIService

package struct MockAPIRequest: APIRequest {
    package typealias ReturnType = MockResponse
    
    package var path: String = "/v2/everything"
    
    package init() {}
    
    package func createQueryItems() -> [URLQueryItem] {
        return [URLQueryItem(name: "q", value: "top")]
    }
}
