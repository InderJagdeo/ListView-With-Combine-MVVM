//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Combine
import Foundation
import UIKit

public protocol NetworkManagerProtocol: Any {
    var session: URLSession { get }
    func request<Route: Router>(_ route: Route) -> Future<Route.Response, Error>
}

public final class NetworkManager: NetworkManagerProtocol {
    public var session: URLSession
    private var cancellables = Set<AnyCancellable>()

    init(_ session: URLSession = .shared) {
        self.session = session
    }

    public convenience init(configuration: URLSessionConfiguration) {
        self.init()
        self.session = URLSession(configuration: configuration)
    }

    public func request<Route: Router>(_ route: Route) -> Future<Route.Response, Error> {
        return Future<Route.Response, Error> {[weak self] promise in

            guard let self = self else {
                return promise(.failure(RequestError.unknown()))
            }

            guard NetworkMonitor.shared.isReachable else {
                return promise(.failure(NetworkError.unreachable()))
            }

            guard let request = route.request() else {
                return promise(.failure(RequestError.invalidURL()))
            }

            NetworkLogger.log(request: request)
            return self.session.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    NetworkLogger.log(response: response)
                    if let response = response as? HTTPURLResponse, !response.statusCode.isSuccess {
                        throw route.errorParser.parse(.mapRequestError(response.statusCode))
                    }
                    return data
                }
                .decode(type: Route.Response.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        NetworkLogger.log(error: error)
                        promise(.failure(route.errorParser.parse(.handleRequestError(error))))
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.cancellables)
        }
    }
}

