//
//  UserRequest.swift
//  ListView
//
//  Created by Macbook on 29/11/22.
//

import Foundation

struct UserRequest: Router {
    typealias Response = [User]
    var method: HTTPMethod = .get
    var parameters: RequestParameters?
    var requestType: RequestType = .data
    var path: String = EndPoint.user.rawValue
}
