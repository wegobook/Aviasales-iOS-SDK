//
//  ProgressView.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 21.08.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

class ProgressView: UIView {

    var progressColor = UIColor.lightGray

    func animateProgress(duration: TimeInterval) {

        let layer = CAShapeLayer()

        layer.path = progressPath().cgPath
        layer.strokeColor = progressColor.cgColor
        layer.lineWidth = bounds.height

        addAnimation(layer: layer, duration: duration)

        self.layer.addSublayer(layer)
    }

    private func progressPath() -> UIBezierPath {

        let path = UIBezierPath()

        path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))

        return path
    }

    private func addAnimation(layer: CAShapeLayer, duration: TimeInterval) {

        let animation = CABasicAnimation(keyPath: "strokeEnd")

        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        layer.add(animation, forKey: "strokeEnd")
    }
}
