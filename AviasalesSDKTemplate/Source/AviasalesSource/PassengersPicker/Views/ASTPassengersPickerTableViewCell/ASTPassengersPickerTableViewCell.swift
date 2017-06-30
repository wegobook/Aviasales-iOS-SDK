//
//  ASTPassengersPickerTableViewCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTPassengersPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var passengersTitleLabel: UILabel!
    @IBOutlet weak var passengersSubtitleLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!

    var minusAction: ((UIButton) -> Void)?
    var plusAction: ((UIButton) -> Void)?

    @IBAction func minusButtonTapped(_ sender: UIButton) {
        minusAction?(sender)
    }

    @IBAction func plusButtonTapped(_ sender: UIButton) {
        plusAction?(sender)
    }
}
