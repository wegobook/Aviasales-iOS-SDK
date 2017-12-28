//
//  CurrencyCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 14.09.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

protocol CurrencyCellModelProtocol {
    var code: String { get }
    var name: String { get }
    var selected: Bool { get }
}

class CurrencyCell: UITableViewCell {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        codeLabel.textColor = JRColorScheme.darkTextColor()
        nameLabel.textColor = JRColorScheme.darkTextColor()
    }

    func setup(_ cellModel: CurrencyCellModelProtocol) {
        codeLabel.text = cellModel.code
        nameLabel.text = cellModel.name
        update(cellModel)
    }

    func update(_ cellModel: CurrencyCellModelProtocol) {
        accessoryType = cellModel.selected ? .checkmark : .none
    }
}
