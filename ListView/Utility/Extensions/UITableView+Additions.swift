//
//  UITableView+Additions.swift
//  ListView
//
//  Created by Macbook on 01/12/22.
//

import Foundation
import UIKit

extension UITableViewCell {
    // MARK: - Class Properties
    static var identifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
