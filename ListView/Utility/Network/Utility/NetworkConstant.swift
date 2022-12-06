//
//  NetworkConstant.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Foundation

public typealias StatusCode = Int
public typealias RequestHeaders = [String: String]
public typealias RequestParameters = [String : Any?]

var kTimeoutInterval: TimeInterval = 30.0
var kNetworkEnvironment: Environment = .development
var kRequestCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData


