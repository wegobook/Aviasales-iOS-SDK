//
//  HLActivityIndicatorTableCell.swift
//  HotelLook
//
//  Created by Oleg on 02/04/15.
//  Copyright (c) 2015 Anton Chebotov. All rights reserved.
//

import UIKit

class HLHotelDetailsActivityIndicatorTableCell: HLHotelDetailsTableCell {
    @IBOutlet weak var indicatorVerticalConstraint: NSLayoutConstraint!

    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Internal methods

    func startAnimating() {
        self.activityIndicator.activityIndicatorViewStyle = .gray
        self.activityIndicator.startAnimating()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
    }
}
