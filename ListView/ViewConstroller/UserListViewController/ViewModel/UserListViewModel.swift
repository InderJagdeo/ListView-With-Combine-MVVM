//
//  ListViewModel.swift
//  ListView
//
//  Created by Macbook on 29/11/22.
//

import Combine
import Foundation

class UserListViewModel {
    
    // MARK: - Properties
    private var users: [User]?
    private var subscriptions = Set<AnyCancellable>()
    private let networkManager: NetworkManagerProtocol
    private let output: PassthroughSubject<Output, Never> = .init()

    // MARK: - Enumerations
    enum Input: Equatable {
        case load
        case refresh
    }

    enum Output { 
        case finish
        case failure(error: Error)
        case success(user: [UserViewModel])
    }

    
    // MARK: - Initializer
    init(_ networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
}

extension UserListViewModel {
    // MARK: - User Defined Methods
        internal func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .load, .refresh:
                self?.requestUsers()
            }
        }.store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }

    internal func user(_ user: UserViewModel) -> User? {
        let user = self.users?.filter({$0.id == user.id})
        return user?.first
    }
}

extension UserListViewModel {
    // MARK: - Web Requests
    
    private func requestUsers() {
        let request = UserRequest()

        let valueHandler: ([User]) -> Void = { [weak self] users in
            self?.users = users
            self?.output.send(.success(user: users.map(UserViewModel.init)))
        }

        let completionHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.output.send(.failure(error: error))
            case .finished:
                self?.output.send(.finish)
            }
        }

        networkManager.request(request)
            .sink(receiveCompletion: completionHandler, receiveValue: valueHandler)
            .store(in: &subscriptions)
    }
}
