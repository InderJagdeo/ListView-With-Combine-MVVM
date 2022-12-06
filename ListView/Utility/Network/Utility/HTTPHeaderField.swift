//
//  HTTPHeaderField.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Foundation

enum HTTPHeaderField: String {
    case acceptType = "Accept"
    case contentType = "Content-Type"
    case authentication = "Authorization"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
    case formData = "multipart/form-data; boundary="
}
