//
//  PriceCalendarChartBarCell.swift
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 10/06/15.
//  Copyright (c) 2015 aviasales. All rights reserved.
//

import UIKit

class PriceCalendarChartBarCell: UICollectionViewCell {

    static let barPadding: CGFloat = 29.0

    static let cornerRadius: CGFloat = 4

    private var departure: JRSDKPriceCalendarDeparture?
    
    @IBOutlet weak var barViewBottomConstraint: NSLayoutConstraint!
    
    override var isSelected: Bool {
        didSet {
            setState()
        }
    }

    @IBOutlet weak var barContainer: UIView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noPriceView: UILabel!

    private var barViewMaskLayer: CAShapeLayer!

    override func awakeFromNib() {
        super.awakeFromNib()

        barView.backgroundColor = JRColorScheme.priceCalendarBarColor()

        barHeightConstraint.constant = 0
        noPriceView.isHidden = true

        barView.layer.cornerRadius = PriceCalendarChartBarCell.cornerRadius
        barViewBottomConstraint.constant = -PriceCalendarChartBarCell.cornerRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setLevels()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.textColor = JRColorScheme.lightTextColor()
        barHeightConstraint.constant = 0
    }

    func setDeparture(_ departure: JRSDKPriceCalendarDeparture?, animated: Bool = false) {
        self.departure = departure
        if let departure = departure {
            let separator = NSLS("COMMA_AND_WHITESPACE")
            dateLabel.text =  DateFormatter(format: "dd\(separator) eee").string(from: departure.date()).arabicDigits()
        }
        setState()
        setLevels(animated: animated)
    }

    private func setState() {

        guard let departure = departure, !departure.isOld() else {
            return
        }

        let isMinimal = PriceCalendarManager.shared.loader?.isMinimalPrice(departure.minPrice(), forMonthOf: departure.date()) ?? false

        if isSelected {
            barView.backgroundColor = isMinimal ? JRColorScheme.priceCalendarSelectedMinBarColor() : JRColorScheme.priceCalendarSelectedBarColor()
            dateLabel.textColor = JRColorScheme.darkTextColor()
            dateLabel.font = UIFont.boldSystemFont(ofSize: dateLabel.font.pointSize)
        } else {
            barView.backgroundColor = isMinimal ? JRColorScheme.priceCalendarMinBarColor() : JRColorScheme.priceCalendarBarColor()
            dateLabel.textColor = JRColorScheme.lightTextColor()
            dateLabel.font = UIFont.systemFont(ofSize: dateLabel.font.pointSize)
        }
    }

    private func setLevels(animated: Bool = false) {

        barViewSetHeight(0)

        var height: CGFloat = 0
        noPriceView.isHidden = true
        if let departure = departure, let minPrice = departure.minPrice() {
            height = PriceCalendarChartBarCell.calculateHeight(for: minPrice.floatValue, bounds: bounds)
        }

        let duration: TimeInterval = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.barViewSetHeight(height)
        }

        if height == 0 {
            noPriceView.isHidden = false
            if departure?.isOld() == true {
                noPriceView.textColor = .white
            } else {
                noPriceView.textColor = JRColorScheme.lightTextColor()
            }
        }
    }

    private func barViewSetHeight(_ height: CGFloat) {
        barHeightConstraint.constant = height
        barContainer.setNeedsLayout()
        barContainer.layoutIfNeeded()
    }

    static func calculateHeight(for price: Float, bounds: CGRect) -> CGFloat {

        guard let maximumDeparturePrice = PriceCalendarManager.shared.loader?.maximumDeparturePrice?.floatValue else {
            return 0
        }
        let minimumBarHeight: CGFloat = 10
        let availableHeight = bounds.height - barPadding - minimumBarHeight
        let multiplier = Double(availableHeight) / Double(maximumDeparturePrice)
        let height = CGFloat(Double(price) * multiplier)

        return height + cornerRadius + minimumBarHeight
    }
}
