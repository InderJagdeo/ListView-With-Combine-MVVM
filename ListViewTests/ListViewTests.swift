//
//  ListViewTests.swift
//  ListViewTests
//
//  Created by Macbook on 29/11/22.
//

import XCTest
import Combine
@testable import ListView

class ListViewTests: XCTestCase {

    var sut: UserListViewModel!
    

    override func setUp() {
        sut = UserListViewModel()
        super.setUp()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
    }

}

class NetworkManagerMock: NetworkManagerProtocol {
    var session: URLSession

    func request<Route>(_ route: Route) -> Future<Route.Response, Error> where Route : Router {
        <#code#>
    }
}
