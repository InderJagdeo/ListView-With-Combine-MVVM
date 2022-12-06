//
//  UserViewModel.swift
//  ListView
//
//  Created by Macbook on 29/11/22.
//

import Foundation

struct UserViewModel: Hashable {

    // MARK: - Properties
    private let user: User

    // MARK: - Initializer
    init(_ user: User) {
        self.user = user
    }
}

extension UserViewModel {
    // MARK: - Get Only Properties
    var id: Int { return user.id }

    var name: String { return user.name }
}
