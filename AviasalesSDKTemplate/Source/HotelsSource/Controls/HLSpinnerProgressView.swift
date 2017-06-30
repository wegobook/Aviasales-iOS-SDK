//
//  HLSpinnerProgressView.swift
//  HotelLook
//
//  Created by Oleg on 17/11/15.
//  Copyright © 2015 Anton Chebotov. All rights reserved.
//

import UIKit

class HLSpinnerProgressView: UIView {

    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var activityIndicatorView: UIActivityIndicatorView!

    fileprivate let defaultWidth: CGFloat = 220.0
    fileprivate let defaultShowDuration: TimeInterval = 0.4

    // MARK: - Override methods

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initialize()
    }

    // MARK: - Internal methods

    func show(_ onView: UIView, animated: Bool) {
        onView.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.alpha = 0.0

        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[selfView]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["selfView": self])
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[selfView]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["selfView": self])
        onView.addConstraints(horizontalConstraint)
        onView.addConstraints(verticalConstraint)
        self.setNeedsLayout()
        self.layoutIfNeeded()

        let duration = (animated ? self.defaultShowDuration : 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(),
            animations: { [weak self] () -> Void in
                self?.alpha = 1.0
            },
            completion: nil)
    }

    func dismiss(_ duration: TimeInterval, delay: TimeInterval, completion: (() -> Void)?) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions(),
            animations: { [weak self] () -> Void in
                self?.alpha = 0.0
            }, completion: { [weak self] (finished) -> Void in
                completion?()
                self?.removeFromSuperview()
        })
    }

    // MARK: - Private methpods

    fileprivate func initialize() {
        self.activityIndicatorView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.activityIndicatorView.startAnimating()
    }

}
