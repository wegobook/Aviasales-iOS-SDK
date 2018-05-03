//
//  PriceCalendarCardCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 05.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class PriceCalendarCardCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func setup(_ view: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(JRConstraintsMakeScaleToFill(containerView, view))
    }
}
