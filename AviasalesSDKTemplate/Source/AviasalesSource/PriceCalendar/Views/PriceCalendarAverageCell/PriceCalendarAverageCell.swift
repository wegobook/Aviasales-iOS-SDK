//
//  PriceCalendarAverageCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 06.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class PriceCalendarAverageCell: UITableViewCell {
    
    @IBOutlet weak var avarageLabel: UILabel!
    @IBOutlet weak var notDirectPriceLabel: UILabel!
    @IBOutlet weak var notDirectTextLabel: UILabel!
    @IBOutlet weak var directPriceLabel: UILabel!
    @IBOutlet weak var directTextLabel: UILabel!
    
    @IBOutlet weak var separatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewHorizontalCenterConstraint: NSLayoutConstraint!

    private var shouldShowSeparator = false

    override func layoutSubviews() {
        super.layoutSubviews()
        let multiplier: CGFloat = isRTL ? -1 : 1
        separatorViewHorizontalCenterConstraint.constant = shouldShowSeparator ? 0 : (multiplier * bounds.width / 2)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        avarageLabel.textColor = JRColorScheme.darkTextColor()
        notDirectPriceLabel.textColor = JRColorScheme.mainColor()
        notDirectTextLabel.textColor = JRColorScheme.darkTextColor()
        directPriceLabel.textColor = JRColorScheme.mainColor()
        directTextLabel.textColor = JRColorScheme.darkTextColor()
        separatorViewWidthConstraint.constant = JRPixel()
    }

    func setup(_ cellModel: PriceCalendarAverageCellModel) {
        avarageLabel.text = cellModel.text
        shouldShowSeparator = cellModel.directPriceInfo == nil ? false : true
        notDirectPriceLabel.text = cellModel.notDirectPriceInfo?.price
        notDirectTextLabel.text = cellModel.notDirectPriceInfo?.text
        directPriceLabel.text = cellModel.directPriceInfo?.price
        directTextLabel.text = cellModel.directPriceInfo?.text
    }
}
