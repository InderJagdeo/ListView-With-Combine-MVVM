//
//  Data+Ext.swift
//  ListView
//
//  Created by SDNA Tech on 15/09/23.
//

import Foundation


extension Data {
    // MARK: - Data
    
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
