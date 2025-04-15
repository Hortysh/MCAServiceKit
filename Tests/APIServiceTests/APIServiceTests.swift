//
//  APIServiceTests.swift
//  MCAServiceKit
//
//  Created by Алексей Садилов on 15.04.2025.
//

import XCTest
import Combine
import APIService

final class APIServiceTests: XCTestCase {
    let apiClient = APIClient()
    var disposeBag: Set<AnyCancellable> = []
    
    func testAPIService() {
        let expectation = expectation(description: "Fetch completes")
        
        apiClient.fetch(MockAPIRequest())
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Request failed with error: \(error.localizedDescription)")
                    expectation.fulfill()
                case .finished:
                    break
                }
            } receiveValue: { response in
                XCTAssertEqual(response.status, "ok")
                XCTAssertTrue(response.totalResults > 0)
                expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
}
