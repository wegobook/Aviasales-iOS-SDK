//
//  InfoScreenVersionCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 20.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

protocol InfoScreenVersionCellProtocol {
    var version: String? { get }
}

class InfoScreenVersionCell: UITableViewCell {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        versionLabel.textColor = JRColorScheme.darkTextColor()
    }

    func setup(cellModel: InfoScreenVersionCellProtocol) {
        versionLabel.text = cellModel.version
    }
}
