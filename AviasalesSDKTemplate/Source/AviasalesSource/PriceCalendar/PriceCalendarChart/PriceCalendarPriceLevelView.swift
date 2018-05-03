//
//  PriceCalendarPriceLevelView.swift
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 19/06/15.
//  Copyright (c) 2015 aviasales. All rights reserved.
//

import UIKit

class PriceCalendarPriceLevelView: UIView {

    private let lineLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(lineLayer)
        lineLayer.strokeColor = JRColorScheme.priceCalendarMinPriceLevelColor().cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = JRPixel()

        isUserInteractionEnabled = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: frame.width, y: 0))

        lineLayer.path = path.cgPath
        lineLayer.frame = bounds
    }
}
