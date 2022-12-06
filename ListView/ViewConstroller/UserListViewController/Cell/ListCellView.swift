//
//  ListViewCell.swift
//  ListView
//
//  Created by Macbook on 29/11/22.
//

import UIKit

class ListCellView: UITableViewCell {

    // MARK: - Properties
    @IBOutlet private weak var userName: UILabel!

    // MARK: - UIView Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

extension ListCellView {
    // MARK: - User Defined Methods
    internal func updateView(_ user: UserViewModel) {
        userName.text = user.name
    }
}
