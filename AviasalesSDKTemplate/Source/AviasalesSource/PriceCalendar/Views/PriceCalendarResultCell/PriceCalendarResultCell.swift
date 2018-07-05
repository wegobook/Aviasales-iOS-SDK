//
//  PriceCalendarResultCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 20.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class PriceCalendarResultCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cheapestContainerView: UIView!
    
    @IBOutlet weak var cheapestLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!

    @IBOutlet weak var cheapestContainerViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateBackground(animated: animated)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateBackground(animated: animated)
    }

    func setup(_ cellModel: PriceCalendarResultCellModel) {
        cheapestContainerViewHeightConstraint.constant = cellModel.cheapest == nil ? 0 : 40
        cheapestContainerView.isHidden = cellModel.cheapest == nil
        cheapestLabel.text = cellModel.cheapest?.uppercased()
        priceLabel.text = cellModel.price
        datesLabel.text = cellModel.dates?.arabicDigits()
    }
}

private extension PriceCalendarResultCell {

    func updateBackground(animated: Bool) {
        let color = isSelected || isHighlighted ? JRColorScheme.itemsSelectedBackgroundColor() : JRColorScheme.itemsBackgroundColor()
        let duration = animated ? 0.3 : 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.containerView.backgroundColor = color
            self?.cheapestContainerView.backgroundColor = color
        }
    }
}
