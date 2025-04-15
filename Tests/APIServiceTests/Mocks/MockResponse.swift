import Foundation

package struct MockResponse: Decodable {
    package let status: String
    package let totalResults: Int
}
