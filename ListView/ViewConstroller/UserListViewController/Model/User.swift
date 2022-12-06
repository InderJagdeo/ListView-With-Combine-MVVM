//
//  User.swift
//  ListView
//
//  Created by Macbook on 29/11/22.
//

import Foundation

struct User: Codable, Hashable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let website: String
    let username: String
    let address: Address
    let company: Company
}

struct Address: Codable, Hashable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
}

struct Geo: Codable, Hashable {
    let lat: String
    let lng: String
}

struct Company: Codable, Hashable {
    let bs: String
    let name: String
    let catchPhrase: String
}
