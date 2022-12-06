//
//  Router+Request.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Foundation

extension Router {

    private func url(with baseURL: String) -> URL? {
        guard var urlComponents = URLComponents(string: url) else {return nil}
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url?.appendingPathComponent(path) else {return nil}
        return url
    }

    public func request() -> URLRequest? {
        guard var url = url(with: url) else { return nil }

        pathParameters.forEach {
            url.appendPathComponent($0)
        }

        var request = URLRequest(url: url)
        if requiresAuth {
            request.setValue("", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
        }

        if requestType == .upload {
            request.setValue(ContentType.formData.rawValue + UUID().uuidString,
                             forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        }

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.cachePolicy = kRequestCachePolicy
        request.timeoutInterval = kTimeoutInterval
        request.httpBody = requestType != .upload ? jsonBody : formDataBody

        return request
    }
}

extension Router {
    private var formDataBody: Data? {
        guard [.post].contains(method), let parameters = parameters else {
            return nil
        }

        let httpBody = NSMutableData()
        let boundary = "Boundary-\(UUID().uuidString)"

        for (key, value) in parameters {
            if key == "imageData", let imageData = value as? ImageData {
                httpBody.append(dataFormField(named: imageData.name, data: imageData.data, mimeType: imageData.memeType, boundary: boundary))
            } else {
                httpBody.append(textFormField(named: key, value: value as! String, boundary: boundary))
            }
        }

        httpBody.append("--\(boundary)--")

        return httpBody as Data
    }

    private var queryItems: [URLQueryItem]? {
        guard method == .get, let parameters = parameters else {
            return nil
        }

        return parameters.map { (key: String, value: Any?) -> URLQueryItem in
            let valueString = String(describing: value)
            return URLQueryItem(name: key, value: valueString)
        }
    }

    private var jsonBody: Data? {
        guard [.post, .put, .patch].contains(method), let parameters = parameters else {
            return nil
        }

        var jsonBody: Data?
        do {
            jsonBody = try JSONSerialization.data(withJSONObject: parameters,
                                                  options: .prettyPrinted)
        } catch {
            print(error)
        }
        return jsonBody
    }
}

extension Router {
    private func textFormField(named name: String, value: Any, boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String, boundary: String) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }
}

