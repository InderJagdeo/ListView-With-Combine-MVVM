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

    private var sut: UserListViewModel!
    private var networkManager: NetworkManagerMock!
    private var subscriptions = Set<AnyCancellable>()
    private let input: PassthroughSubject<UserListViewModel.Input, Never> = .init()

    override func setUp() {
        networkManager = NetworkManagerMock()
        sut = UserListViewModel(networkManager)
        super.setUp()
    }

    override func tearDownWithError() throws {
        sut = nil
        networkManager = nil
        try super.tearDownWithError()
    }

    // MARK: - Test Cases

    func testRequest_OnLoad_isCalled() {
        let output = sut.transform(input: input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "Request Called")
        output.sink(receiveValue: {event in
            expectation.fulfill()
        }).store(in: &subscriptions)

        networkManager.expectation = expectation
        input.send(.load)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(networkManager.expectation)
    }

    func testRequest_With_JsonData_Response() {
        let output = sut.transform(input: input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "Request Called")
        output.sink(receiveValue: {event in
            expectation.fulfill()
            switch event {
            case .fetchUserDidSuccess(let user):
                XCTAssertTrue(!user.isEmpty)
            default:
                break
            }
        }).store(in: &subscriptions)

        networkManager.expectation = expectation
        input.send(.load)
        wait(for: [expectation], timeout: 1.0)
    }

    func testRequest_With_Error() {
        let output = sut.transform(input: input.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "Request Called")
        output.sink(receiveValue: {[weak self] event in
            expectation.fulfill()
            switch event {
            case .fetchUserDidSuccess(let user):
                XCTAssertTrue(!user.isEmpty)
            case .fetchUserDidFail(let error):
                if let error = error as? RequestError {
                    switch error {
                    case .invalidResponse:
                        XCTAssertEqual(error, RequestError.invalidResponse())
                    default:
                        XCTAssertEqual(error, RequestError.unknown())
                    }
                }
            case .fetchUserDidFinish:
                XCTAssertNotNil(self?.networkManager.expectation)
            }
        }).store(in: &subscriptions)

        networkManager.expectation = expectation
        input.send(.load)
        wait(for: [expectation], timeout: 1.0)
    }
}

class NetworkManagerMock: NetworkManagerProtocol {

    var session: URLSession
    var expectation: XCTestExpectation!

    init() {
        self.session = URLSession.shared
    }

    func request<Route>(_ route: Route) -> Future<Route.Response, Error> where Route : Router {
        return Future<Route.Response, Error> {promise in
            if let url = Bundle.main.url(forResource: "Response", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(Route.Response.self, from: data)
                    return promise(.success(jsonData))
                } catch {
                    print("error:\(error)")
                    return promise(.failure(error))
                }
            }
            return promise(.failure(RequestError.unknown()))
        }
    }
}
