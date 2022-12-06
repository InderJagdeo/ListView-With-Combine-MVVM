//
//  Route.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Foundation

public protocol Router {

    associatedtype Response: Codable

    var url: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: RequestHeaders? { get }
    var requiresAuth: Bool { get }
    var requestType: RequestType { get }
    var pathParameters: [String] { get }
    var errorParser: ErrorParserType { get }
    var parameters: RequestParameters? { get }

}

extension Router {
    var url: String { return kNetworkEnvironment.url }
    var requiresAuth: Bool { return true }
    var method: HTTPMethod { return .get }
    var pathParameters: [String] { return [] }
    var parameters: RequestParameters? { return nil }
    var errorParser: ErrorParserType { return ErrorParser()}
    var headers: RequestHeaders? {
        return [
            HTTPHeaderField.acceptType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue
        ]
    }
}

public enum RequestType {
    case data
    case download
    case upload
}

public enum ResponseType {
    case json
    case file
}

