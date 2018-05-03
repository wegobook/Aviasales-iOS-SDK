//
//  PriceCalendarChartHeader.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 14.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class PriceCalendarChartHeader: UIView {
    
    @IBOutlet weak var chartContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if let chartView = PriceCalendarChartView.loadFromNib() {

            chartContainerView.addSubview(chartView)
            chartView.translatesAutoresizingMaskIntoConstraints = false
            chartContainerView.addConstraints(JRConstraintsMakeScaleToFill(chartView, chartContainerView))

            chartView.reloadData()
            chartView.selectCurrentCenterCell()
        }
    }
}
