//
//  PriceCalendarPriceView.swift
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 15/06/15.
//  Copyright (c) 2015 aviasales. All rights reserved.
//

import UIKit

private let arrowWidth: CGFloat = 12.0
private let arrowHeight: CGFloat = 6.0
private let cornerRadius: CGFloat = 6.0
private let noPriceText = "–"

class PriceCalendarPriceView: UIView {

    fileprivate let textLabel = UILabel()
    fileprivate let bubbleLayer = CAShapeLayer()

    fileprivate var widthConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)

        textLabel.textAlignment = NSTextAlignment.center
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
        textLabel.textColor = JRColorScheme.mainColor()
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-19-[textLabel]-19-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["textLabel": textLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[textLabel]-12-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["textLabel": textLabel]))

        textLabel.text = noPriceText

        layer.addSublayer(bubbleLayer)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bubbleLayer.path = makePath(bounds)
        bubbleLayer.fillColor = UIColor.clear.cgColor
        bubbleLayer.strokeColor = JRColorScheme.mainColor().cgColor
    }

    private func makePath(_ rect: CGRect) -> CGPath? {

        let path = CGMutablePath()

        path.move(to: CGPoint(x: 0, y: rect.height/2))

        path.addArc(tangent1End: .zero, tangent2End: CGPoint(x: rect.width, y: 0), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: rect.width, y: 0), tangent2End: CGPoint(x: rect.width, y: rect.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: rect.width, y: rect.height - arrowHeight), tangent2End: CGPoint(x: 0, y: rect.height - arrowHeight), radius: cornerRadius)

        path.addLine(to: CGPoint(x: rect.width/2 + arrowWidth/2, y: rect.height - arrowHeight))
        path.addLine(to: CGPoint(x: rect.width/2, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width/2 - arrowWidth/2, y: rect.height - arrowHeight))

        path.addArc(tangent1End: CGPoint(x: 0, y: rect.height - arrowHeight), tangent2End: .zero, radius: cornerRadius)
        path.addLine(to: CGPoint(x: 0, y: rect.height/2))

        return path.copy()
    }
}

extension PriceCalendarPriceView {

    func setPriceCalendarDeparture(_ departure: JRSDKPriceCalendarDeparture) {

        if let value = departure.minPrice() {
            let format = NSLS("PRICE_CALENDAR_PRICE_VIEW_TEXT")
            let price = JRSDKPrice.price(currency: RUB_CURRENCY, value: value.floatValue)?.formattedPriceinUserCurrency() ?? noPriceText
            textLabel.text = String(format: format, price)
        } else {
            textLabel.text = noPriceText
        }
    }
}
