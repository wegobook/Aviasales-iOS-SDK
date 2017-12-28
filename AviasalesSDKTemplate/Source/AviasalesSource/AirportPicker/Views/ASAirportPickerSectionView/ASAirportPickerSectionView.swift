//
//  ASAirportPickerSectionView.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 03.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

protocol ASAirportPickerSectionViewProtocol {
    var name: String? { get }
}

class ASAirportPickerSectionView: UIView {

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.textColor = JRColorScheme.darkTextColor()
    }

    func setup(sectionModel: ASAirportPickerSectionViewProtocol) {
        nameLabel.text = sectionModel.name
    }
}
