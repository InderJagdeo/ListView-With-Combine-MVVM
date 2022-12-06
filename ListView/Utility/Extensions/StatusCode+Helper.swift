//
//  StatusCode+Helper.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//

import Foundation

extension StatusCode {
    var isSuccess: Bool {
        (200..<300).contains(self)
    }
}
