//
//  ASAirportPickerInfoCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 03.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

protocol ASAirportPickerInfoCellProtocol {
    var loading: Bool { get }
    var info: String { get }
}

private let infoLabelLeadingWithoutActivityIndicator: CGFloat = 20
private let infoLabelLeadingWithActivityIndicator: CGFloat = 48

class ASAirportPickerInfoCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var leadingInfoLabelConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        infoLabel.textColor = JRColorScheme.lightTextColor()
    }

    func setup(cellModel: ASAirportPickerInfoCellProtocol) {
        cellModel.loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        infoLabel.text = cellModel.info
        leadingInfoLabelConstraint.constant = cellModel.loading ? infoLabelLeadingWithActivityIndicator : infoLabelLeadingWithoutActivityIndicator
    }
}
