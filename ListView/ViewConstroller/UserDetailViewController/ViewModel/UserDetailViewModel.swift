//
//  UserDetailViewModel.swift
//  ListView
//
//  Created by Macbook on 30/11/22.
//

import Combine
import Foundation
import CoreLocation

struct UserDetailViewModel {
    // MARK: - Properties
    private let user: User

    // MARK: - Initializer
    init(_ user: User) {
        self.user = user
    }
}

extension UserDetailViewModel {
    // MARK: - Read Only Properties
    var name: String { return user.name }

    var email: String { return user.email }

    var phone: String { return user.phone }

    var website: String { return user.website }

    var companyName: String { return user.company.name }

    var address: String {
        return [user.address.street, user.address.suite, user.address.city, user.address.zipcode].joined(separator: " ")
    }

    var location: CLLocation? {
        if let lat = Double(user.address.geo.lat), let lng = Double(user.address.geo.lng) {
            return CLLocation.init(latitude: lat, longitude: lng)
        }
        else {
            return nil
        }
    }
}
