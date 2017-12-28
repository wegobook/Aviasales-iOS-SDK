//
//  InfoScreenRateCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 18.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

protocol InfoScreenRateCellProtocol {
    var name: String? { get }
}

class InfoScreenRateCell: UITableViewCell {
    @IBOutlet weak var actionButton: UIButton!

    var action: ((UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
    }

    private func setupUI() {
        actionButton.layer.cornerRadius = 4
        actionButton.layer.borderWidth = JRPixel()
        actionButton.layer.borderColor = JRColorScheme.mainColor().cgColor
    }

    func setup(cellModel: InfoScreenRateCellProtocol, action: @escaping (UIButton) -> Void) {
        actionButton.setTitle(cellModel.name, for: .normal)
        self.action = action
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        action?(sender)
    }
}
