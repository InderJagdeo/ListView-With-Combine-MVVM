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
    private var users: [User] = []
    private(set) var listOfUsers: [UserViewModel] = []
    
    private var subscriptions = Set<AnyCancellable>()
    private let networkManager: NetworkManagerProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    
    // MARK: - Enumerations
    enum Input: Equatable {
        case load
        case refresh
    }
    
    enum Output {
        case fetchUserDidFinish
        case fetchUserDidSuccess
        case fetchUserDidFail(error: Error)
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
        let users = self.users.filter({$0.id == user.id})
        return users.first
    }
}

extension UserListViewModel {
    // MARK: - Web Requests
    
    private func requestUsers() {
        let request = UserRequest()
        
        let valueHandler: ([User]) -> Void = { [weak self] users in
            self?.users = users
            self?.listOfUsers = users.map(UserViewModel.init)
            self?.output.send(.fetchUserDidSuccess)
        }
        
        let completionHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.output.send(.fetchUserDidFail(error: error))
            case .finished:
                self?.output.send(.fetchUserDidFinish)
            }
        }
        
        networkManager.request(request)
            .sink(receiveCompletion: completionHandler, receiveValue: valueHandler)
            .store(in: &subscriptions)
    }
}
