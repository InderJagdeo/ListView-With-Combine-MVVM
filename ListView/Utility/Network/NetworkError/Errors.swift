//
//  NetworkError.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Foundation

public enum RequestError: Error, LocalizedError {
    case invalidURL(Error? = nil, String = ErrorMessage.invalidUrl.rawValue)
    case unknown(Error? = nil, String = ErrorMessage.unknowError.rawValue)
    case invalidResponse(Error? = nil, String = ErrorMessage.invalidResponse.rawValue)
    case invalidRequest(Int, String = ErrorMessage.invalidRequest.rawValue)
    case notFound(Int, String = ErrorMessage.serverNotFound.rawValue)
    case forbidden(Int, String = ErrorMessage.forbidden.rawValue)
    case serverError(Int, String = ErrorMessage.serverError.rawValue)
    case unauthorized(Int, String = ErrorMessage.unauthorized.rawValue)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let error, let message):
            return error?.localizedDescription ?? message
        case .unknown(let error, let message):
            return error?.localizedDescription ?? message
        case .invalidResponse(let error, let message):
            return error?.localizedDescription ?? message
        case .invalidRequest(let statusCode, let message):
            return errorMessage(statusCode, error: message)
        case .notFound(let statusCode, let message):
            return errorMessage(statusCode, error: message)
        case .forbidden(let statusCode, let message):
            return errorMessage(statusCode, error: message)
        case .serverError(let statusCode, let message):
            return errorMessage(statusCode, error: message)
        case .unauthorized(let statusCode, let message):
            return errorMessage(statusCode, error: message)

        }
    }

    private func errorMessage(_ statusCode: Int, error: String) -> String {
        return "Status Code: \(statusCode) Error: \(error)"
    }
}

public enum NetworkError: Error, LocalizedError {
    case unreachable(String? = ErrorMessage.unreachable.rawValue)
    public var errorDescription: String? {
        switch self {
        case .unreachable(let message):
            return message
        }
    }
}
