//
//  NSMutableData+Append.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Foundation

extension NSMutableData {
  func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
