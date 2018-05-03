//
//  SearchResultsPriceCalendarView.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 01.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class SearchResultsPriceCalendarView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var overlayView: UIView!
    
    var tapAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = JRColorScheme.mainBackgroundColor()
        containerView.layer.cornerRadius = 6

        titleLabel.text = NSLS("SEARCH_RESULTS_PRICE_CALENDAR_VIEW_TITLE").uppercased()
        titleLabel.textColor = JRColorScheme.darkTextColor()

        if let chartView = PriceCalendarChartView.loadFromNib() {

            chartView.showPriceView = false
            chartView.selectOnScroll = false

            chartContainerView.addSubview(chartView)
            chartView.translatesAutoresizingMaskIntoConstraints = false
            chartContainerView.addConstraints(JRConstraintsMakeScaleToFill(chartView, chartContainerView))

            chartView.reloadData()

            overlayView.addGestureRecognizer(chartView.collectionView.panGestureRecognizer)
        }
    }

    @IBAction func overlayTapped(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }
}
